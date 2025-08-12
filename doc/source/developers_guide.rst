Developers guide
================
To coordinate the development we have established a release schedule and policy
for merge requests.

.. note::
   For experienced professional coders: Most of us are not. We are mainly
   circuit designers. Some of our habits and practices may seem errorneous,
   weird, ancient and inefficient. Please bear with us, and keep in mind that
   we have started from below zero. We are willing to learn, but some of us in
   our organization must understand the concept you are proposing, see the
   benefit, and explain it to others. Otherwise it will turn the majority of
   the development to dogmatic religion and make it even more difficult to our users to
   start using and get into the development of this greatest effort of all
   times. Thank you for your understanding.  -Marko Kosunen

Development branches
--------------------
Development chipndale_template and for each submodule under it is executed
under development branches named 'va.b_RC" where a and b are the numbers fo
major and minor releases, and there is a merge request for those branches for
communication. Smaller develpment sprints can be made in brances named freely
with merge request to the RC-branches. The releases will be tagged 'va.b'

If the RC branch does not exist, there has been nodevelopment since the last
release. In that case, please create the branch and a merge request for it.

Project access levels:
----------------------
* Main branch of the project should be protected.
* Only 'Maintainers' should be able to push to protected branches.
* 'Developers' should be able to merge to protected branches.

Process for gaining access to TheSyDeKick group
-------------------------------------------------

Among the contributors, we saw a need to agree on policy how the access rights
and access levels are granted to people willing to participate the development.
The reason being that with the great power comes a great responsibility, and
the principle (as in system managing in general) is that privileges are
minimized by default to the minimum level necessary.

.. The privileges of the
  access levels are reported `https://docs.gitlab.com/ee/user/permissions.html
  <https://docs.gitlab.com/ee/user/permissions.html>`_

1. 'Owner' rights are granted only if they are absolutely needed. They are
   primarily granted to persons who a) represents a trusted organization. b)
   Has a need to manage members, projects and groups, and edit the content of
   the whole 'TheSyDeKick' group with full access and more power than
   'maintainer'. Access is granted per request from at least two contributors
   with 'owner' rights.

2. 'Maintainer' rights are granted to persons who a) represents a trusted
   organization. b) Has a need to manage members, projects and groups, and edit
   the content of the 'TheSyDeKick' group with more rights and more power than
   'developer'. Access is granted per request from at least two contributors
   with 'maintainer' rights.

3. 'Developer' rights are granted by 'maintainers' per request. Maintainers
   should grant 'developer' access only to a) trusted members of their
   organizations, b) trusted members that represent some organizational
   contributor they have personally met.

Individuals outside organizations - Process of gaining trust.
.............................................................

Motivation: with more access rights you get more visibility to for example
confidential issues (like this) and activities in this group. You become 'more
involved' contributor.

1. At No access: File pull/merge requests from a fork and ask for a review.
   . After 5 merged requests you may be granted 'reporter' rights per request
   to at least two maintainers.

2. At Reporter rights: File pull/merge requests and demonstrate activity and skill.
   After 5 merged requests 'developer' rights may be granted per request from
   at least three 'maintainers'.

3. At Developer rights: 'maintainer' rights for individual should be an
   exception. The 'maintainer' access may be granted by proposing a
   group/project wide action that a) requires maintainer rights b) is discussed
   and agreed in one or more issues or merge requests involving developers and
   maintainers. c) Received as in good idea and accepted to be implemented.
   'maintainer' access may be granted after second acceptance of this kind of
   proposal per request from at least two 'maintainers' supported by at least
   two 'developers'. Maintainer access from an individual member may be revoked
   if an individual maintainer adds members to the project without following
   this procedure. Access will be also revoked from all members added by that
   individual maintainer.

