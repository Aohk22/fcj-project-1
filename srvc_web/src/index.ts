import index from '../public/index.html'; 

const server = Bun.serve({
  port: 8001,
  hmr: false,
  routes: {
    "/": index,

    "/query": async (req) => {
      const hash = await req.body.text();
      const res = await fetch(`http://local-api.dev.lan/query/?file_hash=${hash}`, { method: 'GET' });
      // const res = await fetch(`http://localhost:4101/query/?file_hash=${hash}`, { method: 'GET' });
      console.log(res);
      if (res.ok) {
        return new Response(await res.blob());
      }
      return new Response('File not found', { status: 404 });
    },

    "/analyze": async (req) => {
      const form = new FormData();
      form.append("raw", await req.body.blob());
      const res = await fetch('http:///local-api.dev.lan/upload/', { method: 'POST', body: form});
      // const res = await fetch('http://localhost:4100/upload/', { method: 'POST', body: form });
      if (res.ok) {
        return new Response(await res.blob());
      }
      return new Response('Internal Error', { status: 500 });
    },
  },
});

console.log(`Listening on ${server.url}`);
