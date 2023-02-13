import http from 'node:http';
import fetch from 'node-fetch';

const server = http.createServer();
const url = "https://kazwire.com";
const PORT = process.env.PORT || 3000;

server.on('request', async (req, res) => {
  const reqUrl = req.url === "*" ? "/" : req.url
  const asset = await fetch(url + reqUrl);
  const body = new Buffer.from(await asset.arrayBuffer());
  res.writeHead(asset.status, { "Content-Type": asset.headers.get("content-type").split(";")[0] });
  res.end(body);
});

server.listen(PORT)