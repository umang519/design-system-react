# Project Document: Design System React

A single-page overview of what this repository contains, how it is built and tested, and where the work stands. For coding conventions, see [codebase-overview.md](codebase-overview.md). For contributor setup, see [CONTRIBUTING.md](../CONTRIBUTING.md).

## 1. Summary

| Item          | Value                                                                                        |
| ------------- | -------------------------------------------------------------------------------------------- |
| Package       | `@salesforce/design-system-react`                                                            |
| Version       | `11.0.0-alpha.4`, published under the `alpha` npm tag (0.10.x stays on `latest`)             |
| Purpose       | Accessible, presentational React components for the Salesforce Lightning Design System       |
| Stack         | React 19.2, TypeScript (`strict`), SLDS 2 (`@salesforce-ux/design-system-2`)                 |
| Toolchain     | Node >= 24, Vite 8, Vitest 4 + Playwright, Storybook 10, ESLint 10, Prettier                 |
| License       | BSD-3-Clause                                                                                 |
| Also included | A Salesforce DX source tree (`force-app/`) with Apex, Lightning Web Components, and metadata |

The repository has two separate parts:

1. **The React component library** is the main product, published to npm.
2. **Salesforce org metadata** in `force-app/main/default` is synced from a Salesforce org. It is not part of the npm package, which ships only `dist`, `README.md`, and `LICENSE.txt`, and the library build does not use it.

## 2. Goals

- Offer the React version of approved SLDS patterns only, with markup that matches SLDS.
- Meet WCAG 2.1 AA, with keyboard navigation and screen-reader support.
- Ship TypeScript types as the public contract. Runtime PropTypes were removed.
- Support SLDS 2 themes (Lightning Blue, Cosmos) and light, dark, and system color schemes.
- Reach a stable v11 with a frozen prop API (see [ROADMAP.md](../ROADMAP.md)).

## 3. Repository Layout

```
design-system-react/
├── components/        # 57 component folders + index.js barrel, settings, story registry
│   └── __tests__/     # Story HTML snapshot suite
├── utilities/         # Shared non-public helpers (DOM, keyboard, focus, IDs, warnings, hooks)
├── types/             # Shared TypeScript types (common, components, theme)
├── styles/            # Supplemental styles (use sparingly, prefer SLDS classes)
├── icons/, assets/    # Icon and static assets
├── eslint-plugin/     # Project ESLint rules
├── scripts/           # Build tooling, e.g. generate-entry-shims.mjs
├── .storybook/        # Storybook 10 config, themes, dark-mode decorator
├── .github/workflows/ # ci.yml, chromatic.yml, npm-publish.yml
├── docs/              # Codebase overview, PR/issue templates, platform notes
└── force-app/         # Salesforce DX metadata (separate from the library)
```

### Component catalog

Accordion, Alert, Avatar, Badge, Breadcrumb, Builder Header, Button, Button Group, Button Stateful, Card, Carousel, Checkbox, Color Picker, Combobox, Date Picker, Docked Composer, Dynamic Icon, Expandable Section, Files, Filter, Forms, Grid, Icon, Icon Settings, Illustration, Input, Media Object, Menu Dropdown, Menu List, Modal, Page Header, Panel, Pill, Pill Container, Popover, Portal Settings, Progress Bar, Progress Indicator, Progress Ring, Radio, Radio Button Group, Radio Group, Scoped Notification, Setup Assistant, Simple Data Table, Slider, Spinner, Split View, Tabs, Textarea, Toast, Tooltip, Tree, Trial Bar, Vertical Navigation, Visual Picker, Welcome Mat.

### Component folder layout

| File                     | Purpose                                       |
| ------------------------ | --------------------------------------------- |
| `index.tsx`              | Public export                                 |
| `[component].tsx`        | Implementation                                |
| `types.ts`               | Prop types (the public API)                   |
| `private/`               | Internal subcomponents, not public API        |
| `__docs__/*.stories.tsx` | Storybook stories, also used as test fixtures |
| `__examples__/`          | Example usage                                 |

## 4. Architecture

- **Function components and hooks** on React 19.
- **Positioning** uses `@floating-ui/dom`. `utilities/dialog-helpers.js` converts its output to the older popper-style shape that dialog-based popups still expect.
- **Overlays** (modal, popover, tooltip, menus) render through portals and `react-modal`. `portal-settings` and `icon-settings` provide app-wide context.
- **Styling** uses SLDS classes and SLDS 2 styling hooks (`var(--slds-g-*)`). Hard-coded SLDS 1 tokens were removed.
- **Distribution**: ES modules, CommonJS, and `.d.ts` files, exposed through the `exports` map (`.`, `./components/*`, `./utilities/*`). `sideEffects: false` allows tree-shaking.
- **Peer dependencies**: `react`, `react-dom`, and `@salesforce-ux/design-system`, which supplies the icons.

## 5. Development Workflow

| Command                  | Purpose                                                    |
| ------------------------ | ---------------------------------------------------------- |
| `npm run storybook`      | Storybook dev server on port 6007                          |
| `npm run typecheck`      | `tsc --noEmit`                                             |
| `npm run lint`           | ESLint; must report 0 errors                               |
| `npm test -- --run`      | jsdom `unit`, Playwright `browser`, and snapshot suites    |
| `npm test -- --run -u`   | Same, and regenerates story HTML snapshots                 |
| `npm run test:snapshots` | Story snapshot suite only                                  |
| `npm run build`          | Type-check, Vite library build, `.d.ts` files, entry shims |
| `npm run test:ci`        | Everything CI runs                                         |

Process rules:

- Conventional commits, enforced by commitlint through Husky. Breaking changes use `!` and a `BREAKING CHANGE:` footer.
- Husky hooks: `pre-commit` runs lint-staged, and `pre-push` blocks the push when story snapshots are stale.
- Lint and formatting changes go in their own `style:` commit.
- PRs follow [PULL_REQUEST_TEMPLATE.md](PULL_REQUEST_TEMPLATE.md). Bug fixes need a root cause and a regression test.

## 6. Quality and Testing

- **Unit tests (jsdom)** with Testing Library and `user-event`.
- **Browser tests** (`*.browser.test.jsx`) run in real Chromium through Playwright, for focus traversal and layout measurement.
- **Story snapshots**: every non-portal story is rendered to HTML in `components/__tests__/__snapshots__/story-snapshots.test.jsx.snap`. Changing a story or a component's markup means updating and committing that snapshot.
- **Visual review**: Chromatic runs on push (`chromatic.yml`).
- **Accessibility**: the Storybook a11y addon and `jsx-a11y` lint rules.
- **CI** (`ci.yml`) runs on pushes and PRs to `master`/`main`: `npm ci`, Playwright Chromium install, then `npm run test:ci`.

## 7. Release Process

- A GitHub Release triggers `.github/workflows/npm-publish.yml`, which publishes to npm under the `alpha` tag.
- Release notes go in [CHANGELOG.md](../CHANGELOG.md) (Keep a Changelog, SemVer).
- At GA, `publishConfig.tag` changes from `alpha` to `latest` and the README version table is updated.

## 8. Current Status and Roadmap

Highlights from [ROADMAP.md](../ROADMAP.md):

- Component sources are TypeScript. `components/utilities/dialog/index.jsx` is the last `.jsx` source.
- `tsc` is clean under `strict`. Lint reports 0 errors and 223 warnings, which are the tracked migration backlog.
- 48 Vitest test files. Three component folders have no story: `forms`, `grid`, `menu-list`.

Remaining P1 work toward a stable v11:

- [ ] Fix the `components/<name>` entry points for `ColorPicker`, `Filter`, and `Tree`.
- [ ] Write a 0.10.x → v11 migration guide.
- [ ] Publish hosted v11 docs and Storybook.
- [ ] Use one release tag format.
- [ ] Land the breaking changes from the prop API freeze review before GA: remove deprecated props, make data and selection controlled, type child and slot contracts, switch callbacks to `(event, data)`, and rename booleans to `is*`/`has*`.

Recent notable changes: `DataTable` renamed to `SimpleDataTable` (alpha.4), several components removed (alpha.3: AppLauncher, BrandBand, Expression, GlobalHeader, GlobalNavigationBar, LocationMap), and SLDS 1 design tokens replaced with SLDS 2 styling hooks.

## 9. Salesforce Org Metadata (`force-app/`)

Salesforce DX source synced from an org. There is no `sfdx-project.json` in the repo, so deploying it needs a separately configured Salesforce project.

| Type            | Contents                                                                                                                                                                                                                                                                            |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Apex classes    | 10 classes and 11 test classes, covering case assignment, priority, activity, web form; lead follow-up and assignment; quick lead search; opportunity pipeline chart                                                                                                                |
| Trigger         | `CaseTrigger` (before insert/update) → `CaseTriggerHandler` → `CaseAssignmentService`                                                                                                                                                                                               |
| LWC (12)        | `caseActivitySummary`, `caseReassignmentPanel`, `caseSummaryCard`, `caseWebForm`, `createFollowUpTask`, `leadAssignmentFollowUp`, `leadFollowUpDashboard`, `leadQualificationPanel`, `myFirstComponent`, `opportunityApprovalStatus`, `opportunityPipelineChart`, `quickLeadSearch` |
| Custom objects  | `Contact_Detail__c`, `Contact_Details__c`, `Employee_Onboarding_Record__c`, `Feedback__c`, `Service_Request__c`                                                                                                                                                                     |
| Custom metadata | `Case_Assignment_Rule__mdt` (4 records: Default, Hardware NA High, Services APAC Low, Software EU Medium), `Lead_Routing_Rule__mdt`                                                                                                                                                 |
| Flows           | Employee onboarding record creation, lead assignment on region update, opportunity approval submission, report export protection                                                                                                                                                    |
| Other           | 18 FlexiPages, 173 page layouts, 11 permission sets, a Case workflow, and a `chartJs` static resource                                                                                                                                                                               |

Main business flows:

- **Case routing**: when a case is created or its category, region, or priority changes, the case is assigned using `Case_Assignment_Rule__mdt` keys. Agents can reassign a case with the `caseReassignmentPanel` LWC.
- **Case intake**: the `caseWebForm` LWC (Experience Cloud page) validates input and creates cases through `CaseWebFormController`.
- **Lead management**: quick lead search, lead follow-up dashboard, assign-to-me and status updates, and creating follow-up tasks.
- **Opportunity insights**: a pipeline chart by stage (Chart.js) and approval status.

## 10. Risks and Open Questions

- **Two projects in one repo.** The library and the org metadata have separate lifecycles. Consider moving `force-app/` to its own repository, or adding `sfdx-project.json` and `.forceignore` so it can be deployed.
- **Alpha API churn.** Breaking prop changes are still planned. Consumers should pin exact versions.
- **Broken subpath imports** for ColorPicker, Filter, and Tree until the entry-shim fix lands.
- **No hosted v11 docs** yet. This README, Storybook run locally, and the CHANGELOG are the only references.
- **Lint warning backlog** (223) needs to shrink before GA.
