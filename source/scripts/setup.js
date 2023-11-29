import Helpers from './helpers.js';

import * as Prompts from '@clack/prompts';
import LanguageCodes from 'iso-lang-codes';

Prompts.intro(`Setup`);

let settings = await Helpers.loadSettings();

settings['wiki-url'] = await Prompts.text({
  message: 'Wiki URL',
  placeholder: 'https://wiki.example.com',
  initialValue: settings['wiki-url'] ? settings['wiki-url'] : "https://",
  required: true,
  validate(value) {
    if (!value.match(Helpers.URL_REGEX)) {
      return "Invalid URL";
    }
  }
});

settings['wiki-api-token'] = await Prompts.text({
  message: 'Wiki API Token',
  placeholder: 'eyJhbGciOiJSUzI1NiIsInR5cCI6Ik...',
  initialValue: settings['wiki-api-token'],
  required: true,
});

settings['title'] = await Prompts.text({
  message: 'Title',
  placeholder: 'My Wiki Book',
  initialValue: settings['title'],
  required: true,
  validate(value) {
    if (value.length <= 0) {
      return "Title can not be empty";
    }
  }
});

settings['subtitle'] = await Prompts.text({
  message: 'Subtitle',
  placeholder: 'First Edition',
  initialValue: settings['subtitle'],
  required: false,
});

settings['author'] = await Prompts.text({
  message: 'Author',
  placeholder: 'My Wiki Community',
  initialValue: settings['author'],
  required: false,
});

settings['subject'] = await Prompts.text({
  message: 'Subject',
  placeholder: 'My Wiki',
  initialValue: settings['subject'],
  required: false,
});

settings['keywords'] = await Prompts.text({
  message: 'Kewords',
  placeholder: 'wiki, book, community',
  initialValue: settings['keywords'],
  required: false,
  validate(value) {
    if (!value.match(Helpers.KEYWORD_LIST_REGEX)) {
      return "Invalid keyword list. Use commas to separate keywords";
    }
  },
});

settings['language'] = await Prompts.text({
  message: 'Language',
  placeholder: 'en-US',
  initialValue: settings['language'],
  required: false,
  validate(value) {
    if (!LanguageCodes.validateLocaleCode(value) && !LanguageCodes.validateLanguageCode(value)) {
      return "Invalid language code. Use IETF language tags followed by a BCP 47 tag.";
    }
  },
});

settings['date-format'] = await Prompts.text({
  message: 'Date Format',
  placeholder: 'MMMM YYYY',
  initialValue: settings['date-format'] ? settings['date-format'] : "MMMM YYYY",
  required: false,
});

settings['add-pageref'] = await Prompts.confirm({
  message: 'Should links be followed by a page reference? Example "See Article Foo (Page 35)"',
  initialValue: settings['add-pageref']
});

if (settings['available-tabs'] && settings['available-tabs'].length > 0) {

  if (await Prompts.confirm({
    message: 'Should all tabs be shown?',
    initialValue: (settings['selected-tabs'] == [])
  })) {
    settings['selected-tabs'] = [];
    settings['show-tab-headings'] = true;
  } else {
    settings['selected-tabs'] = await Prompts.multiselect({
      message: 'Select which tabs should be included.',
      options: settings['available-tabs'].map((tab) => { return { value: tab, label: tab } }),
      initialValues: settings['selected-tabs'],
      required: false,
    });
    settings['show-tab-headings'] = false;
  }
}

const settings_spinner = Prompts.spinner();
settings_spinner.start(`Save Selection`);
await Helpers.saveSettings(settings);
settings_spinner.stop(`Save Selection [Done]`);

Prompts.outro(``);