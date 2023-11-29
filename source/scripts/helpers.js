import FS from 'node:fs';

export default class Helpers {

  static URL_REGEX = /^(https?):\/\/([\w\d-]+\.[\w\d-.]+)([\/\w\d-_.]*)/;
  static KEYWORD_LIST_REGEX = /^([^,\s]+(, [^,\s]+)*)?$/;

  static async readFile(file) {
    return await FS.promises.readFile(file, 'utf-8')
  }

  static async writeFile(file, content) {
    return await FS.promises.writeFile(file, content, 'utf-8')
  }

  static writeStream(file) {
    return FS.createWriteStream(file);
  }

  static readStream(file) {
    return FS.createReadStream(file);
  }

  static async loadSettings(exitOnError = false) {
    let settings = {}
    try {
      let content = await this.readFile('settings.json');
      if (content != undefined)
        settings = JSON.parse(content);
    } catch (error) {
      if (exitOnError) {
        Console.error('Failed to load settings. Did you run the download and setup command?');
        process.exit(1);
      }
    }
    return settings;
  }

  static checkSettings(settings, exitOnError = false) {
    let validated = true;
    if (settings['wiki-url'] === undefined ||
      settings['wiki-url'] == '' ||
      settings['wiki-url'].match(this.URL_REGEX) == null) {
      validated = false;
    }

    if (settings['title'] === undefined ||
      settings['title'] == '') {
      validated = false;
    }

    if (!validated) {
      Console.error('Not all required settings specified. Pleas run setup command.');
      if (exitOnError) {
        process.exit(1);
      }
    }
  }

  static async saveSettings(settings) {
    return await Helpers.writeFile('settings.json', JSON.stringify(settings, null, 2));
  }

  static markdownFilterIncludes(markdown) {
    let includes = [];
    Array.from(markdown.matchAll(/\{\s*(?:[^\s}]+\s+)*include=['"](\S+)['"](?:\s+[^\s}]+)*\s*\}/gi)).forEach(match => {
      if (match[1]) {
        let include = match[1];
        if (include.startsWith('/'))
          include = include.substring(1);
        includes.push(include);
      }
    });
    return includes;
  }

  static markdownFilterImages(markdown) {
    let images = [];
    Array.from(markdown.matchAll(/!\[([\S ]*?)\]\(([\S]*)(?: *=([\d]+)x)?\)/g)).forEach(match => {
      if (match[2]) {
        images.push(match[2]);
      }
    });
    return images;
  }

  static markdownFilterTabs(markdown) {
    let tabs = [];
    let lastTabsetHeadingLevel = undefined;
    const lines = markdown.split('\n');
    for (let line of lines) {
      line = line.trim();
      // Check if line is a heading
      if (line.startsWith('#')) {
        const headingLevel = line.match(/^#+/)[0].length;
        const headingText = line.replace(/^#+/, '').trim();
        // Check if heading is one level below a current tabset
        if (lastTabsetHeadingLevel !== undefined && (headingLevel - 1) === lastTabsetHeadingLevel) {
          const tab = headingText;
          tabs.push(...[tab].filter(tab => !tabs.includes(tab)));
        } // Check if traversed outside a tabset
        else if (lastTabsetHeadingLevel !== undefined && headingLevel <= lastTabsetHeadingLevel) {
          lastTabsetHeadingLevel = undefined;
        } // Check if heading is a tabset
        else if (lastTabsetHeadingLevel == undefined && headingText.match(/{\s*.tabset\s*}/i)) {
          lastTabsetHeadingLevel = headingLevel;
        }
      }
    }
    return tabs;
  }
}

