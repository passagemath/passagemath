# Contributing to passagemath #

passagemath is a fork of SageMath. It is intended to merge new releases
of SageMath into passagemath on a regular basis.

For now, direct code contributions to passagemath are limited to changes
that support the goals of the fork outlined in [README.md](README.md).
All other changes should be submitted to the SageMath project if you can.

Another way to contribute to passagemath is to prepare pull requests
that send some of passagemath's changes to the upstream SageMath project.
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
