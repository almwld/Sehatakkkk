const sources = [
  'https://images.unsplash.com/photo-1579154204601-01588f351e67?auto=format&fit=crop&w=1200&q=85',
  'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1200&q=85',
  'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?auto=format&fit=crop&w=1200&q=85',
  'https://images.unsplash.com/photo-1581093458791-9d42e3c2f6d0?auto=format&fit=crop&w=1200&q=85',
  'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&w=1200&q=85',
  'https://images.unsplash.com/photo-1576086213369-97a306d36557?auto=format&fit=crop&w=1200&q=85',
  'https://images.unsplash.com/photo-1581595219315-a187dd40c322?auto=format&fit=crop&w=1200&q=85',
  'https://images.unsplash.com/photo-1582719471384-894fbb16e074?auto=format&fit=crop&w=1200&q=85',
  'https://images.unsplash.com/photo-1579154341098-e4e6c4d2c3f4?auto=format&fit=crop&w=1200&q=85',
];

const publicId = process.env.IMAGEKIT_PUBLIC_KEY || 'fqcynk86c';
const privateKey = process.env.IMAGEKIT_PRIVATE_KEY;
const endpoint = 'https://upload.imagekit.io/api/v1/files/upload';

if (!privateKey) {
  console.error('IMAGEKIT_PRIVATE_KEY is required.');
  process.exit(1);
}

async function upload(url, fileName) {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`download ${response.status}: ${url}`);
  const blob = await response.blob();
  const form = new FormData();
  form.append('file', blob, fileName);
  form.append('fileName', fileName);
  form.append('folder', '/images/labs');
  form.append('useUniqueFileName', 'false');
  const auth = Buffer.from(`${privateKey}:`).toString('base64');
  const result = await fetch(endpoint, {
    method: 'POST',
    headers: { Authorization: `Basic ${auth}` },
    body: form,
  });
  const body = await result.text();
  if (!result.ok) throw new Error(`upload ${result.status}: ${body}`);
  return JSON.parse(body);
}

(async () => {
  for (let i = 0; i < 15; i++) {
    const fileName = `lab_${i + 1}.jpg`;
    const source = sources[i % sources.length];
    const result = await upload(source, fileName);
    console.log(`${fileName}: ${result.url}`);
  }
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
