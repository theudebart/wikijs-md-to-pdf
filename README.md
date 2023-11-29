# WikiJS to PDF Converter

This project is designed to convert WikiJS content written in Markdown format into PDF documents.
This only works with pages written in Markdown.

## Setup

### Wiki Access

To get started, acquire a GraphQL API Token from your WikiJS instance. If you need assistance, refer to the [WikiJS Documentation - GraphQL API](https://docs.requarks.io/dev/api).

### Install Pandoc and LaTeX

Make sure to install Pandoc and LaTeX. For installation instructions, visit [Pandoc Installation](https://pandoc.org/installing.html).

Additionally, add the following LaTeX packages using the TeX Live Manager (tlmgr):

```bash
sudo tlmgr install titlesec hyperref bookmark geometry amsmath setspace babel xcolor adjustbox float svg booktabs multirow footnotebackref footmisc listings mdframed upquote cleveref wrapfig
```

## Build

Follow these steps to build and generate output for this project.

1. **Download Repository:**

    - Clone the repository to your local machine:
        ```bash
        git clone https://github.com/theudebart/wikijs-md-to-pdf.git
        cd wikijs-md-to-pdf
        ```

2. **Install Dependencies:**

    - Run the following command to install project dependencies:
        ```bash
        npm install
        ```

3. **Setup Configuration:**

    - Configure the project settings by running:
        ```bash
        npm run setup
        ```
        Answer the prompted questions to set up your preferences.

4. **Write Content:**

    - Create the `main.md` file with your desired content. Look at `example.md` for an example of `main.md`. This is like writing the Table of Contents (TOC) where you define which pages from your WikiJS should be included.

5. **Download Resources:**

    - Download required resources from the WikiJS by running:
        ```bash
        npm run download
        ```

6. **Build the Project:**
    - Generate the PDF Document:
        ```bash
        npm run build
        ```

That's it! Your project should now be built successfully, and the output can be found in the output folder.

## Template

This project provides a LaTeX template for you to use. The template file is located at `/template/template.latex`. Edit this template according to your preferences.

## Options

### Unlisted

To exclude headers and all headers below from the Table of Contents, add the class `.unlisted` to the parent header.
Example:

```md
# Not Visible {.unlisted}

## Not Visible
```

To hide all children headers but not the parent header, use the class .unlisted-children.
Example:

```md
# Visible {.unlisted-children}

## Not Visible
```

### Image Sizes

In WikiJS, you can control the size of images using the following syntax:

```md
![Image Caption](/images/....png =700x)
```

This example sets the image width to 700 pixels.

```md
![Image Caption](/images/....png =45%x)
```

This example sets the image to be 45% of the screen width.

Images with a width set to percentages are converted to percentage of the print media.
Pixels base image sizes can be tricky due to different DPIs on various devices. As a workaround, pixel sizes are converted based on a 1024px width being considered 100% of the print media width. For example, an image intended to be 512px wide will be translated to 50% of the print media width.

### Image Captions

Since WikiJS does not render image captions directly, a workaround is to write image captions below the image in cursive text.
Here's an example:

```md
![Image Caption](/images/....png)
_Image Caption_
```

In this example, the cursive text below the image serves as the image caption. It's important to note that these cursive texts will be utilized as image captions and will be automatically removed from the output during processing.
This approach allows you to include meaningful captions for your images while working within the limitations of the WikiJS rendering.

### Pagebreaks and Hide on Print

By default, WikiJS does not include a page break option as it is not designed for printed media. However, to generate a page break in printed media, you can add the following:

```md
<div class="pagebreak"></div>
```

to your markdown.
This will create a page break when the content is printed.

To hide content specifically on print media, you can encapsulate the content in a div with the class .hide-on-print. Here's an example:

```md
<div class="hide-on-print">
# Hidden on Print
This content is only visible in the web browser but not on printed media.
</div>
```

Additionally, to ensure the same behavior when someone prints from the browser, add the following CSS to your site style:

```css
@media print {
	.hide-on-print {
		display: none !important;
	}
	.pagebreak {
		page-break-after: always;
	}
}
```

This CSS code hides content with the class .hide-on-print and ensures a page break after elements with the class .pagebreak when printing from the browser.

## Contribute

Thank you for considering contributing to this project!
I welcome and encourage contributions.
If you're interested in contributing, here's how you can help.

### Issues

If you encounter any issues or have suggestions for improvements, please open an issue. I'll do my best to address them.

### Pull Requests

Pull requests are highly appreciated! If you have a fix or enhancement, feel free to submit a pull request.

### Git Flow

This repository utilizes git-flow, a highly regarded branching model that streamlines the development process. To effectively navigate this workflow, follow these guidelines:

1. Feature Branches:

Create a feature branch for each new implementation or bug fix.
Prefix feature branches with feature/ followed by a descriptive name, e.g. feature/my-enhancement.
Once the feature is complete, merge the feature branch into the develop branch.
If you have installed git-flow you can use `git flow feature start my-enhancement` and `git flow feature finish my-enhancement`

2. Hotfix Branches:

For urgent bug fixes, create a hotfix branch using the prefix hotfix/ followed by a brief description, e.g. hotfix/critical-security-patch.
Merge the hotfix branch directly into the master branch, ensuring stability.
Backport the hotfix branch to the develop branch for long-term maintenance.
If you have installed git-flow you can use `git flow hotfix start <new version> critical-security-patch` and `git flow hotfix finish <new version>`.

Additional information can be found in the [git-flow cheatsheet](https://danielkummer.github.io/git-flow-cheatsheet/).

## Personal Note

I currently don't have the time to actively contribute to the development of this project, as it already fulfills my specific use case. However, I believe it can be a valuable starting point for anyone looking to convert their WikiJS content to PDF.

-   This project is a work in progress and is far from perfect.
-   The code quality may not be optimal, but it gets the job done for my needs.

Feel free to explore and build upon this project, and contributions are always welcome! If you encounter issues or have suggestions for improvement, consider opening an issue or submitting a pull request.

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3). The GPLv3 is a free software license that allows users to use, copy, modify, and distribute the project as long as the source is not disclosed.

For more information about the GPLv3, please visit the Free Software Foundation website [www.gnu.org (GPL-3.0)](https://www.gnu.org/licenses/gpl-3.0.html).

For an easy to understand overview of the license visit [choosealicense.com (GPL-3.0)](https://choosealicense.com/licenses/gpl-3.0/)
