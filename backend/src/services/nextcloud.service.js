const axios = require('axios');

class NextcloudService {
  constructor() {
    this.baseUrl = process.env.NEXTCLOUD_URL?.replace(/\/$/, '');
    this.username = process.env.NEXTCLOUD_USERNAME;
    this.password = process.env.NEXTCLOUD_PASSWORD;
    this.rootPath = process.env.NEXTCLOUD_ROOT_PATH || 'Sehatak';

    if (!this.baseUrl || !this.username || !this.password) {
      throw new Error(
        'NEXTCLOUD_URL, NEXTCLOUD_USERNAME and NEXTCLOUD_PASSWORD are required'
      );
    }
  }

  getAuthHeader() {
    return {
      Authorization:
        'Basic ' +
        Buffer.from(`${this.username}:${this.password}`).toString('base64'),
    };
  }

  sanitize(value) {
    return String(value)
      .replace(/\.\./g, '')
      .replace(/[\/\\]/g, '_')
      .replace(/[^a-zA-Z0-9_\-.]/g, '_');
  }

  buildPath(chatId, messageId, fileName) {
    const safeChatId = this.sanitize(chatId);
    const safeMessageId = this.sanitize(messageId);
    const safeFileName = this.sanitize(fileName);

    return `${this.rootPath}/${safeChatId}/${safeMessageId}/${safeFileName}`;
  }

  async createDirectory(path) {
    const parts = path.split('/');

    let currentPath = '';

    for (const part of parts) {
      if (!part) continue;

      currentPath += `/${part}`;

      const url =
        `${this.baseUrl}/remote.php/dav/files/` +
        `${encodeURIComponent(this.username)}${currentPath}`;

      try {
        await axios({
          method: 'MKCOL',
          url,
          headers: this.getAuthHeader(),
          validateStatus: status =>
            status === 201 ||
            status === 405 ||
            status === 409,
        });
      } catch (error) {
        throw new Error(
          `Failed to create Nextcloud directory: ${currentPath}`
        );
      }
    }
  }

  async uploadBuffer({
    chatId,
    messageId,
    fileName,
    buffer,
    mimeType = 'application/octet-stream',
  }) {
    const directory = this.buildPath(
      chatId,
      messageId,
      ''
    ).replace(/\/$/, '');

    await this.createDirectory(directory);

    const safeFileName = this.sanitize(fileName);

    const remotePath =
      `${directory}/${safeFileName}`;

    const url =
      `${this.baseUrl}/remote.php/dav/files/` +
      `${encodeURIComponent(this.username)}/${remotePath}`;

    const response = await axios.put(url, buffer, {
      headers: {
        ...this.getAuthHeader(),
        'Content-Type': mimeType,
        'Content-Length': buffer.length,
      },
      maxContentLength: Infinity,
      maxBodyLength: Infinity,
    });

    if (![201, 204].includes(response.status)) {
      throw new Error(
        `Nextcloud upload failed: HTTP ${response.status}`
      );
    }

    return {
      provider: 'nextcloud',
      remotePath,
      fileName: safeFileName,
      mimeType,
      url,
    };
  }

  async deleteFile(remotePath) {
    const url =
      `${this.baseUrl}/remote.php/dav/files/` +
      `${encodeURIComponent(this.username)}/${remotePath}`;

    const response = await axios.delete(url, {
      headers: this.getAuthHeader(),
    });

    return response.status === 204;
  }
}

module.exports = new NextcloudService();
