import index from './index.html'; 

const server = Bun.serve({
	port: 8000,
	routes: {
		"/": index,
		"/analyze": async (req) => {
      const res = await fetch('http://192.168.44.167:8001/upload/', {
        method: 'POST',
        headers: {
          'Content-Type': await req.headers.get('Content-Type'),
        },
        body: await req.body,
      });
			return res;
		},
	},
});

console.log(`Listening on ${server.url}`);
