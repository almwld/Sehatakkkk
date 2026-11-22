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

    console.log('☁️ Nextcloud configured:', {
      baseUrl: this.baseUrl,
      username: this.username,
      rootPath: this.rootPath,
    });
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

  buildPath(chatId, messageId, fileName = '') {
    const safeChatId = this.sanitize(chatId);
    const safeMessageId = this.sanitize(messageId);

    let path =
      `${this.rootPath}/${safeChatId}/${safeMessageId}`;

    if (fileName) {
      path += `/${this.sanitize(fileName)}`;
    }

    return path;
  }

  getDavUrl(remotePath = '') {
    const encodedUsername = encodeURIComponent(this.username);

    const cleanPath = String(remotePath)
      .replace(/^\/+/, '')
      .split('/')
      .map(encodeURIComponent)
      .join('/');

    return (
      `${this.baseUrl}/remote.php/dav/files/` +
      `${encodedUsername}/${cleanPath}`
    );
  }

  async createDirectory(path) {
    const parts = path
      .split('/')
      .filter(Boolean);

    let currentPath = '';

    for (const part of parts) {
      currentPath += `/${part}`;

      const remotePath = currentPath.replace(/^\/+/, '');
      const url = this.getDavUrl(remotePath);

      console.log('📁 MKCOL:', url);

      try {
        const response = await axios({
          method: 'MKCOL',
          url,
          headers: this.getAuthHeader(),
          validateStatus: () => true,
        });

        console.log('📁 MKCOL response:', {
          status: response.status,
          path: remotePath,
        });

        if (![201, 405].includes(response.status)) {
          const error = new Error(
            `Nextcloud MKCOL failed: HTTP ${response.status}`
          );

          error.response = response;
          throw error;
        }
      } catch (error) {
        console.error('❌ MKCOL ERROR');

        console.error('message:', error.message);
        console.error('status:', error.response?.status);
        console.error('data:', error.response?.data);

        throw error;
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
    if (!Buffer.isBuffer(buffer)) {
      throw new Error('uploadBuffer requires a Buffer');
    }

    const directory = this.buildPath(
      chatId,
      messageId
    );

    console.log('☁️ Upload directory:', directory);

    await this.createDirectory(directory);

    const safeFileName = this.sanitize(fileName);

    const remotePath =
      `${directory}/${safeFileName}`;

    const url = this.getDavUrl(remotePath);

    console.log('⬆️ Nextcloud PUT:', {
      url,
      remotePath,
      fileName: safeFileName,
      mimeType,
      size: buffer.length,
    });

    try {
      const response = await axios.put(
        url,
        buffer,
        {
          headers: {
            ...this.getAuthHeader(),
            'Content-Type': mimeType,
            'Content-Length': buffer.length,
          },
          maxContentLength: Infinity,
          maxBodyLength: Infinity,
          validateStatus: () => true,
        }
      );

      console.log('⬆️ PUT response:', {
        status: response.status,
        statusText: response.statusText,
      });

      if (![201, 204].includes(response.status)) {
        const error = new Error(
          `Nextcloud upload failed: HTTP ${response.status}`
        );

        error.response = response;
        throw error;
      }

      console.log('✅ Nextcloud upload successful');

      return {
        provider: 'nextcloud',
        remotePath,
        fileName: safeFileName,
        mimeType,
        url,
      };
    } catch (error) {
      console.error('');
      console.error('========== NEXTCLOUD PUT ERROR ==========');
      console.error('message:', error.message);
      console.error('status:', error.response?.status);
      console.error('statusText:', error.response?.statusText);
      console.error('data:', error.response?.data);
      console.error('url:', error.config?.url);
      console.error('method:', error.config?.method);
      console.error('=========================================');
      console.error('');

      throw error;
    }
  }

  async deleteFile(remotePath) {
    const url = this.getDavUrl(remotePath);

    const response = await axios.delete(url, {
      headers: this.getAuthHeader(),
    });

    return response.status === 204;
  }
}

module.exports = new NextcloudService();
