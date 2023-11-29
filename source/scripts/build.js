import Helpers from './helpers.js';

import Path from 'node:path';
import FS from 'node:fs';
import ChildProcess from 'node:child_process';
import Moment from 'moment';
import Console from 'consola';
import * as Prompts from '@clack/prompts';

let settings = await Helpers.loadSettings(true);
Helpers.checkSettings(settings, true);

Prompts.intro(`Setup`);
const setup_spinner = Prompts.spinner();
setup_spinner.start(`Check LaTeX Template`);
// Check if file already exists
if (!FS.existsSync('./template/template.latex')) {
  FS.copyFileSync('./template/example.latex', './template/template.latex')
  setup_spinner.stop(`Check LaTeX Template [Use Example Template]`);
} else {
  setup_spinner.stop(`Check LaTeX Template [Done]`);
}
Prompts.outro(``);

Prompts.intro(`Conversion`);
const build_spinner = Prompts.spinner();
build_spinner.start(`Converting`);

let output_file_format = '.pdf';
if (settings['debug'] == true)
  output_file_format = '.latex';

let output_file = Path.join('.', 'output', 'output' + output_file_format);

if (settings['title'] != undefined)
  output_file = Path.join('.', 'output', settings['title'] + output_file_format);

// Create output path if not exists
await FS.promises.mkdir(Path.dirname(output_file), { recursive: true });

const options = [
  `./main.md`,
  `-o`, `${output_file}`,
  `--from`, `markdown+hard_line_breaks+emoji`,
  `--resource-path`, `.:./content/assets`,
  `--template`, `./template/template.latex`,
  `--wrap=preserve`,
  `--lua-filter`, `./source/filters/include.lua`,
  `--lua-filter`, `./source/filters/tabs.lua`,
  `--lua-filter`, `./source/filters/hide.lua`,
  `--lua-filter`, `./source/filters/toc.lua`,
  `--lua-filter`, `./source/filters/images.lua`,
  `--lua-filter`, `./source/filters/image-captions.lua`,
  `--lua-filter`, `./source/filters/lists.lua`,
  `--lua-filter`, `./source/filters/quotes.lua`,
  `--lua-filter`, `./source/filters/links.lua`,
  `--lua-filter`, `./source/filters/pagebreak.lua`,
  `--lua-filter`, `./source/filters/linebreak.lua`
];

if (settings['title'] != undefined)
  options.push(`--metadata`, `title=${settings['title']}`);

if (settings['subtitle'] != undefined)
  options.push(`--metadata`, `subtitle=${settings['subtitle']}`);

if (settings['author'] != undefined)
  options.push(`--metadata`, `author=${settings['author']}`);

if (settings['subject'] != undefined)
  options.push(`--metadata`, `subject=${settings['subject']}`);

if (settings['language'] != undefined)
  options.push(`--metadata`, `lang=${settings['language']}`);

let date = Moment().locale(settings['language']).format('LL');
if (settings['date-format'] != undefined)
  date = Moment().format(settings['date-format']);
options.push(`--metadata`, `date=${date}`);

if (settings['selected-tabs'] != undefined)
  options.push(`--variable`, `selected-tabs="${settings['selected-tabs'].join(':')}"`);

if (settings['show-tab-headings'] != undefined)
  options.push(`--variable`, `show-tab-headings="${settings['show-tab-headings']}"`);

if (settings['add-pageref'] != undefined)
  options.push(`--variable`, `add-pageref="${settings['add-pageref']}"`);

if (settings['debug'] == true)
  options.push(`--verbose`);


let error = '';
const child = ChildProcess.spawn('pandoc', options, {
  cwd: './',
});
child.stdout.on('data', (data) => {
  process.stdout.write(data);
});

child.stderr.on('data', (data) => {
  error = error + data;
});

child.on('error', (error) => {
  build_spinner.stop(`Converting [Failed]`);
  Prompts.outro(``);
  Console.error('Pandoc Error: ' + error);
  child.stdin.pause();
  child.kill();
  process.exit(1);
});

child.on('close', (code) => {
  if (error != '') {
    build_spinner.stop(`Converting [Failed]`);
    Prompts.outro(``);
    Console.error('Pandoc Error: ' + error);
  } else {
    build_spinner.stop(`Converting [Done]`);
    Prompts.outro(``);
    Console.info('Saved file to: ' + output_file);
  }
});