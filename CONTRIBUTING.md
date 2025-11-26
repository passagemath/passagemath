# Contributing to passagemath #

passagemath is a compatible fork of SageMath.

We merge new releases of SageMath into passagemath on a regular basis.

## Direct code/documentation contributions to passagemath (recommended)

On 2025-09-01, the passagemath project was opened to general
code contributions.  Submit pull requests to the [main passagemath
repository](https://github.com/passagemath/passagemath) or other
repositories in the [passagemath GitHub organization](https://github.com/passagemath).

PRs will be reviewed by the passagemath project's maintainer.
Members of the passagemath organization and the general public are invited to
contribute to reviewing PRs.

All participation in passagemath is subject to the Code of Conduct.
Code contributions to passagemath are limited to those that
do not conflict with the goals of the fork outlined in [README.md](README.md).

## Code/documentation contributions to upstream SageMath (caution advised)

As we merge new releases of SageMath into passagemath on a regular basis,
it is also possible to contribute to passagemath indirectly, by opening
pull requests in the [SageMath project](https://github.com/sagemath/sage).

Caution is advised. As of 2025, SageMath is not a safe environment.

## Contributing by sending passagemath changes to upstream SageMath

Another way to contribute to passagemath is to prepare pull requests
that send selected passagemath changes to the upstream SageMath project.

For example, modularization considerations in passagemath may make it
necessary to split a source file into two.

Upstreaming such changes can help with avoiding merge conflicts later.

The passagemath pull requests labeled "Upstream candidate",
https://github.com/passagemath/passagemath/pulls?q=is%3Apr+label%3A%22Upstream+candidate%22,
are a basis for such efforts.

- Such PRs are best opened with a title in the form
  "ORIGINALTITLE by @ORIGINALAUTHOR, backported".
  This ensures that the correct attribution is shown in the automatically
  generated release notes in https://github.com/sagemath/sage/releases

- Please include a link to the original PR in the description.

- Use `git cherry-pick` or `git rebase --onto` to prepare a branch
  backported to the SageMath `develop` branch.

## Contributing to passagemath by backporting SageMath PRs

Although we already merge new releases of SageMath into passagemath on a
regular basis, earlier backports of selected changes made in the SageMath
project are welcome.

As passagemath makes frequent stable releases, in particular bug fixes
in the Sage library, updates of packages in the Sage distribution, and
portability improvements are good candidates for backporting to
passagemath.

- Such PRs are best opened with a title in the form
  "ORIGINALTITLE by @ORIGINALAUTHOR, backported" or
  "ORIGINALTITLE by @ORIGINALAUTHOR, rebased".
  This ensures that the correct attribution is shown in the automatically
  generated release notes in https://github.com/passagemath/passagemath/releases

- Please include a link to the original PR in the description.
  There is no need to copy-paste the original description.

- Use `git cherry-pick` or `git rebase --onto` to prepare a branch
  backported to the passagemath `main` branch.

## Non-code contributions to passagemath

There are many other ways to contribute to the passagemath project.

For example, help popularize the project by sharing project announcements
in mailing lists and on social media.

The passagemath project does not accept financial sponsorship.

## Contributing to the larger mathematical software ecosystem

The passagemath project is a major integrating force in the
[mathematical software landscape](https://github.com/passagemath#passagemath-in-the-mathematical-software-landscape).

passagemath depends on numerous open-source mathematical software
packages.  Contributing to the development and maintenance of
dependencies is a great way to contribute to passagemath, too.

Publishing your own packages that depend on passagemath is also a
wonderful way to contribute to the passagemath project and the
mathematical software ecosystem.

You are also invited to help with curation activities for mathematical
software.

- For user packages that depend on the Sage library, curation
  activities are coordinated in
  [passagemath/passagemath#248](https://github.com/passagemath/passagemath/issues/248).

- Regarding other mathematical software, we invite the public to open
  an Issue at https://github.com/passagemath/passagemath/issues to
  describe the scope of the curation and initial examples of software
  to be surveyed.
