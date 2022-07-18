import 'dotenv/config';
import * as fs from "fs";
export function node_url(networkName: string): string {
    if (networkName) {
      const uri = process.env['ETH_NODE_URI_' + networkName.toUpperCase()];
      if (uri && uri !== '') {
        return uri;
      }
    }
  
    if (networkName === 'localhost') {
      // do not use ETH_NODE_URI
      return 'http://localhost:8545';
    }
  
    let uri = process.env.ETH_NODE_URI;
    if (uri) {
      uri = uri.replace('{{networkName}}', networkName);
    }
    if (!uri || uri === '') {
      // throw new Error(`environment variable "ETH_NODE_URI" not configured `);
      return '';
    }
    if (uri.indexOf('{{') >= 0) {
      throw new Error(
        `invalid uri or network not supported by node provider : ${uri}`
      );
    }
    return uri;
  }

  export function accounts(networkName?: string): {privateKey: string | undefined} {
    return {privateKey: process.env.PRIVATE_KEY || undefined};
  }

  export function storeAddress(filename:string, content:string) {
        fs.writeFileSync(__dirname + "/" + filename + ".log", content);
  }

  export function readAddress(filename:string):string {
    return fs.readFileSync(__dirname + "/" + filename + ".log").toString()
  }