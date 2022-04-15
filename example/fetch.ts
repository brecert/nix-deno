import { parse } from "https://deno.land/std@0.135.0/flags/mod.ts";

if (import.meta.main) {
  const parsedArgs = parse(Deno.args, {
    string: ["out"],
    alias: {
      out: "o",
    },
  });

  if (!parsedArgs._[0]) {
    console.error(`usage: example https://example.com [--out|-o output]`);
    Deno.exit(1);
  }

  const url = parsedArgs._[0].toString();
  const res = await fetch(url);
  const body = new Uint8Array(await res.arrayBuffer());

  if (parsedArgs.out) {
    await Deno.writeFile(parsedArgs.out, body);
  } else {
    await Deno.stdout.write(body);
  }
}
