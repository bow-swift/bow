# Guidelines to contribute to Bow

We appreciate any contributions to help Bow move forward. Note that we have a [code of conduct](CODE_OF_CONDUCT.md); please, follow it in all your interactions with the project.

## How you can help

There are several things you can do to help Bow grow:

- **Report bugs and malfunctioning issues**: Use the [issue template](https://github.com/bow-swift/bow/issues/new?assignees=Maintainers&labels=&template=bug.md&title%5B%5D=Bug) for *bugs* and provide as much detail as possible to help us find the cause of the problem, reproduce it, and fix it. Please, take your time to go through the list of open issues in order to make sure they are not duplicated.
- **Suggest new features**: Use the [issue template](https://github.com/bow-swift/bow/issues/new?assignees=Maintainers&labels=&template=feature_request.md&title%5B%5D=Request) for *feature requests* to suggest a new feature or integration in the library. Do not proceed to the implementation of the new feature until it has been discussed in the issue comments. You can also join the [Gitter channel for Bow](https://gitter.im/bowswift/bow) for longer discussions.
- **Implement approved features**: After a suggested feature has been discussed and approved, you can get assigned to the corresponding issue and implement it. Contributions need to go through a code review process. Follow the instructions below for pull requests.
- **Add API Reference docs**: The API for Bow needs to be documented. [This issue](https://github.com/bow-swift/bow/issues/59) keeps track of what is already documented or in progress. If you want to contribute to adding API docs, pick an item from the list and create an individual issue so that everyone is aware that such task is already being done.

## Documentation

Bow provides a section in its microsite where its documentation is [published](https://bow-swift.io/docs) in the form of tutorial-like articles. If you want to contribute by adding an article here, this is what you need.

### Installation

- Make sure you have Xcode, [CocoaPods](https://cocoapods.org/), and [brew](https://brew.sh/index_es) installed in your computer.
- Install [nef](https://nef.bow-swift.io). `nef` is a tool that we use to enforce compile-time correctness of the docs to conform to the latest version of the library. In order to install it, you need to run:

```
brew install nef
```

- Clone the repository for Bow
- Go to the folder where you have cloned Bow
- Run `nef compile --project Documentation.app` to set up the project with its dependencies
- Open `Documentation.app`

### Adding content

If you pay attention to the project structure, you can see that it has multiple Xcode Playgrounds that mirror the side bar of [this page](https://bow-swift.io/docs). You can also see that the Playground pages for each section match the pages inside each section on the web.

- If you want to add a new section, you just need to add a new Playground and place it in the order you want it to appear on the website.
- If you want to add a new page within a section, you just need to add a new page to the corresponding Playground.

In order to add documentation, use the standard Markdown format used in Xcode Playgrounds. For reference, you can check it out in the [official documentation from Apple](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/index.html).


### Compiling documentation

Once you are done, you can check that your document compiles properly by moving to the root directory of the Bow project and running the following command:

```
nef compile --project Documentation.app
```

If everything is correct, your document should be ready for publication.

### Rendering content locally

If you want to check how your documentation will be rendered once it is published, you need to follow these steps:

- Run the following command from the root directory to generate the site:

```
nef jekyll --project Documentation.app --output docs --main-page Documentation.app/Jekyll/Home.md
```

- You can install the dependencies you need with:

```
bundle install --gemfile docs/Gemfile --path vendor/bundle
```

- If you also want to render the API reference, run:

```
./scripts/gen-docs.rb
```

- Once it is done, you can set up a local server with the site by running:

```
BUNDLE_GEMFILE=./docs/Gemfile bundle exec jekyll serve -s ./docs
```

- The site will be available at the URL [http://127.0.0.1:4000](http://127.0.0.1:4000). Note: syntax highlighting may not render properly if you do not generate the API reference.

## Pull request process

When you add a code contribution to Bow, you need to open a new pull request. Please, note the following considerations:

- Use the pull request template and fill all the sections that are applicable.
- If you are contributing a **new typeclass**, make sure its methods are properly documented. Also, any laws that instances of the typeclass must obey need to be implemented and included in the same PR.
- If you are contributing a **new data type**, make sure it includes instances for typeclasses where applicable. Add tests to verify the instances of typeclasses for this data type satisfy the corresponding laws.
- If you are adding a **new integration with a library or framework**, make sure it is in a separate target and it has the minimum dependencies it needs in order to work. It must have its own test target. Be sure to update the `Package.swift` to build this new target with its dependencies.
- In general, all code that is committed to the project should be tested. Use property-based testing where applicable.
- In general, all code that is committed to the project should be documented. Refer to other files to see the formatting and style of the documentation.
