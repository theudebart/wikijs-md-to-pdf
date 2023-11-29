import Helpers from './helpers.js';

import Console from "consola";
import * as Prompts from '@clack/prompts';
import FS from 'node:fs';
import Path from 'node:path';
import Http from 'node:http';
import Https from 'node:https';
import { GraphQLClient, gql } from 'graphql-request';

export default class WikiJsApi {
    client = undefined;
    url = undefined;
    host = undefined;
    protocol = 'https';
    access_token = undefined;
    pages = undefined;
    settings = {}

    async setup() {
        let settings = await Helpers.loadSettings(true);
        Helpers.checkSettings(settings, true);

        this.url = settings['wiki-url'];
        this.protocol = this.url.match(Helpers.URL_REGEX)[1];
        this.host = this.url.match(Helpers.URL_REGEX)[2];

        this.access_token = settings['wiki-api-token'];
        this.authorizationBearer = `Bearer ${settings['wiki-api-token']}`

        this.client = new GraphQLClient(`${this.protocol}://${this.host}/graphql`, {
            headers: {
                Authorization: this.authorizationBearer,
            }
        });

        Console.info(` WikiJs API Endpoint: ${this.client.url}`);
    }

    constructor() {
    }

    async getPages() {
        try {
            let request = await this.client.request(gql`
            query {
                pages {
                    list (orderBy: TITLE) {
                    id
                    path
                    title
                    }
                }
            }`)
            if (request.pages == undefined || request.pages.list == undefined || request.pages.list.length == 0) {
                Console.error('No pages found. Check Wiki API Token for access rights.');
                process.exit(1);
            }
            return request.pages.list;
        } catch (error) {
            if (error.response && error.response.errors) {
                Console.error('Error occured while accessing Wiki API: ' + error.response.errors[0].message);
            } else {
                Console.error('Error occured while accessing Wiki API: ' + error.message);
            }
            process.exit(1);
        }
    }

    async getPage(id) {
        try {
            let request = await this.client.request(gql`
                query($id: Int!) {
                pages {
                    single(id: $id) {
                    path
                    title
                    content
                    }
                }
            }`, { id: id })
            if (request.pages == undefined || request.pages.single == undefined) {
                Console.error(`No page with ID ${id} found. Check Wiki API Token for access rights.`);
                process.exit(1);
            }
            return request.pages.single;
        } catch (error) {
            if (error.response && error.response.errors) {
                Console.error('Error occured while accessing Wiki API: ' + error.response.errors[0].message);
            } else {
                Console.error('Error occured while accessing Wiki API: ' + error.message);
            }
            process.exit(1);
        }
    }

    async downloadPage(directory, path, override = false) {
        return new Promise(async (resolve, reject) => {
            // Define paths
            let remotePath = path;
            let localPath = Path.join(directory, Path.dirname(remotePath), Path.basename(remotePath) + '.md');
            // Retrieve page list
            if (this.pages == undefined)
                this.pages = await this.getPages();
            this.pages = await this.getPages();
            // Chek if path exists in pages
            let page = this.pages.find(page => page.path == (remotePath));
            if (page == undefined) {
                return resolve(['NOT_FOUND', undefined]);
            }
            // Download page
            page = await this.getPage(page.id)
            // Check if file already exists
            if (!override && FS.existsSync(localPath)) {
                return resolve(['ALREADY_EXISTS', page.content]);
            }
            // Create path if not exists
            await FS.promises.mkdir(Path.dirname(localPath), { recursive: true });
            // Write to File
            await FS.promises.writeFile(localPath, page.content);
            resolve(['DOWNLOADED', page.content]);
        });
    }

    async downloadAsset(directory, path, override = false) {
        return new Promise(async (resolve, reject) => {
            // Define paths
            let remotePath = path;
            let localPath = Path.join(directory, Path.dirname(remotePath), Path.basename(remotePath));
            // Check if file already exists
            if (!override && FS.existsSync(localPath)) {
                return resolve(['ALREADY_EXISTS']);
            }
            // Create download path if not exists
            await FS.promises.mkdir(Path.dirname(localPath), { recursive: true });
            // Download file
            const file = await FS.createWriteStream(localPath);
            const protocol = this.protocol == 'https' ? Https : Http;
            const headers = {}
            const request = await protocol.get({
                host: this.host, path: encodeURI(remotePath), headers: {
                    Authorization: this.authorizationBearer,
                }
            }, (response) => {
                response.pipe(file);
                response.on('end', () => {
                    resolve(['DOWNLOADED']);
                })
                response.on('error', (error) => {
                    console.dir(error)
                    reject(['FAILED']);
                })
            });
        })
    }
}