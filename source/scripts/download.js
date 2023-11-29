import WikiJsApi from './api.js';
import Helpers from './helpers.js';

import Console from "consola";
import * as Prompts from '@clack/prompts';

const images = [];
const pages = [];
const tabs = [];
let pages_tried = 0;
let pages_not_found = 0;

// Read main.md
let main = undefined;
try {
  main = await Helpers.readFile('main.md');
} catch (error) {
  Console.error('Failed to load main.md. Did you already create a main.md?');
  process.exit(1);
}

let API = new WikiJsApi();
Prompts.intro(`Setup`);
const override = !await Prompts.confirm({
  message: 'Skip existing pages and images?',
});
await API.setup();
Prompts.outro(``);

// Search for Pages
pages.push(...Helpers.markdownFilterIncludes(main).filter(page => !pages.includes(page)));
// Download Pages
Prompts.intro(`Download Pages`);
const page_spinner = Prompts.spinner();
for (let page of pages) {
  page_spinner.start(`Page ${page}`);
  let [result, content] = await API.downloadPage('content/pages', page, override);
  if (result == 'ALREADY_EXISTS') {
    page_spinner.stop(`Page ${page} [Skipped]`);
  } else if (result == 'NOT_FOUND') {
    page_spinner.stop(`Page ${page} [Not Found]`);
    pages_not_found++;
  } else {
    page_spinner.stop(`Page ${page} [Done]`);
  }
  pages_tried++;

  if (content != undefined) {
    // Search for Images
    images.push(...Helpers.markdownFilterImages(content).filter(image => !images.includes(image)));
    // Search for Tabs
    tabs.push(...Helpers.markdownFilterTabs(content).filter(tab => !tabs.includes(tab)));
  }
};
Prompts.outro(``);
// Download Images
Prompts.intro(`Download Images`);
const image_spinner = Prompts.spinner();
for (let image of images) {
  image_spinner.start(`Image ${image}`);

  let [result] = await API.downloadAsset('content/assets', image, override);
  if (result == 'ALREADY_EXISTS') {
    image_spinner.stop(`Image ${image} [Skipped]`);
  } else {
    image_spinner.stop(`Image ${image} [Done]`);
  }
};
Prompts.outro(``);
if (pages_not_found / pages_tried > 0.3) {
  Console.warn(`Seems like a lot of pages were not found. Check correct path and Wiki API Token.`);
}
// Write available Tabs
if (tabs.length > 0) {
  Prompts.intro(`Analyze Available Tabs`);
  const settings_spinner = Prompts.spinner();
  settings_spinner.start(`Save Settings`);
  let settings = await Helpers.loadSettings(true);
  settings['available-tabs'] = tabs;
  await Helpers.saveSettings(settings);
  settings_spinner.stop(`Save Settings [Done]`);
  Prompts.outro(``);

  Console.warn(`Seems like you use tabs. Run the setup command to configure the usage of tabs.`);
}