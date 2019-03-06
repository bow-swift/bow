# Guidelines to contribute to Bow

We appreciate any contributions to help Bow move forward. Note that we have a [code of conduct](CODE_OF_CONDUCT.md); please, follow it in all your interactions with the project.

## How you can help

There are several things you can do to help Bow grow:

- **Report bugs and malfunctioning issues**: Use the [issue template](https://github.com/bow-swift/bow/issues/new?assignees=Maintainers&labels=&template=bug.md&title%5B%5D=Bug) for *bugs* and provide as much detail as possible to help us find the cause of the problem, reproduce it and fix it. Please, take your time to go through the list of open issues in order to make sure they are not duplicated.
- **Suggest new features**: Use the [issue template](https://github.com/bow-swift/bow/issues/new?assignees=Maintainers&labels=&template=feature_request.md&title%5B%5D=Request) for *feature requests* to suggest a new feature or integration in the library. Do not proceed to the implementation of the new feature until it has been discussed in the issue comments. You can also join the [Gitter channel for Bow](https://gitter.im/bowswift/bow) for longer discussions.
- **Implement approved features**: After a suggested feature has been discussed and approved, you can get assigned to the corresponding issue and implement it. Contributions need to go through a code review process. Follow the instructions below for pull requests.
- **Add documentation**: The API for Bow needs to be documented. [This issue](https://github.com/bow-swift/bow/issues/59) keeps track of what is already documented or in progress. If you want to contribute to adding API docs, pick an item from the list and create an individual issue so that everyone is aware that such task is already being done.

## Pull request process

When you add a code contribution to Bow, you need to open a new pull request. Please, take the following considerations:

- Use the pull request template and fill all the sections that are applicable.
- If you are contributing a **new typeclass**, make sure its methods are properly documented. Also, any laws that instances of the typeclass must obey to, must be implemented and included in the same PR.
- If you are contributing a **new data type**, make sure it includes instances for typeclasses where applicable. Add tests to verify the instances of typeclasses for this data type satisfy the corresponding laws.
- If you are adding a **new integration with a library or framework**, make sure it is in a separate target and it has the minimum dependencies it needs in order to work. It must have its own test target. Be sure to update [Travis](https://github.com/bow-swift/bow/blob/master/.travis.yml) to build this new target.
- In general, all code that is committed to the project should be tested. Use property-based testing where applicable.
