---
title: Changelog
description: Releases and changes in a chronological order.
nav_order: 100
---

# Changelog

### **0.16.1** - *July 21, 2026*
  - feat: System notifications for admins

### **0.16.0** - *July 4, 2026*
  - feat: improve metric source selection and add caching for billing entitlements.
  - feat: add telemetry around billing access checks and metric fetching.
  - fix: prevent duplicate timeline generation and Tabler rendering.
  - refactor: consolidate exports and split organization, dashboard, token, SSO, connector, transponder, and billing concerns into focused modules.
  - refactor: extract a shared page shell for dashboard, explore, and monitor views.

### **0.15.13** - *July 1, 2026*
  - feat: distinguish nested paths from regular paths in widget groups.
  - feat: make progress indicators less obstructive.
  - fix: unify the client and admin sidebars.
  - fix: limit widget-group hover handling to the active widget.

### **0.15.12** - *May 28, 2026*
  - feat: fetch connector-backed series concurrently.
  - feat: add a Kubernetes connector example.
  - fix: add the missing connector homepage action.

### **0.15.11** - *May 28, 2026*
  - feat: expand connector support for querying remote metrics databases.
  - feat: add connector-backed value fetching and connection checks.

### **0.15.10** - *May 27, 2026*
  - fix: correct the private-connection database migration.

### **0.15.9** - *May 25, 2026*
  - feat: enable organization-level private database connections through Trifle Connector.
  - feat: add connector management, authentication, and connection-status handling.

### **0.15.8** - *May 24, 2026*
  - feat: add secure database connection options, including SSH tunnels and a forwarding agent.
  - feat: improve feedback when applying FilterBar changes.

### **0.15.7** - *May 18, 2026*
  - feat: add visual editing for series aliases and priority.
  - fix: defer UI updates while editing filter settings.

### **0.15.6** - *May 18, 2026*
  - feat: support aliases for wildcard series.
  - feat: add a keyboard-shortcuts reference modal.
  - fix: improve the ordering of alias, sorting, and priority controls.

### **0.15.5** - *May 17, 2026*
  - feat: add FilterBar keyboard shortcuts.
  - fix: correct footer button height and chevron orientation.

### **0.15.4** - *May 14, 2026*
  - feat: improve the mobile dashboard experience.
  - fix: improve dashboard grid management.

### **0.15.3** - *May 12, 2026*
  - feat: improve Baker state and tab synchronization.
  - fix: improve context detection and conversation flow.

### **0.15.2** - *May 11, 2026*
  - fix: correct widget-group path previews.
  - fix: improve widget-group title contrast.

### **0.15.1** - *May 10, 2026*
  - feat: expand widget groups from wildcard paths.
  - docs: update the product screenshot.

### **0.15.0** - *May 7, 2026*
  - feat: add quick search.
  - fix: improve widget-group rendering in single-column layouts.
  - fix: correct tooltips for series without data.

### **0.14.10** - *April 29, 2026*
  - feat: improve KPI widgets.
  - fix: correct series autocomplete rendering.

### **0.14.9** - *April 28, 2026*
  - refactor: restructure client-side JavaScript.
  - fix: reduce offscreen timeseries activity and improve mouse handling.
  - fix: correctly export widgets.
  - fix: clarify new widget-group placeholder text.

### **0.14.8** - *April 23, 2026*
  - feat: allow users to resubscribe after canceling a subscription.

### **0.14.7** - *April 23, 2026*
  - fix: correct billing fixtures.

### **0.14.6** - *April 23, 2026*
  - feat: make subscription and SaaS usage handling more robust.
  - feat: improve the billing flow.
  - feat: refine annotations.

### **0.14.5** - *April 20, 2026*
  - feat: add chart annotations.
  - fix: improve autocomplete rendering and chart resizing.
  - fix: add source context to the page header.
  - fix: refine navbar shortcut styling.

### **0.14.4** - *April 17, 2026*
  - feat: redesign the Baker chat header and source visualization.
  - feat: keep Baker state synchronized across tabs.
  - fix: remove the legacy chat interface and correct Baker references and avatars.
  - fix: improve keyboard toggling behavior.

### **0.14.3** - *April 16, 2026*
  - fix: correct chart hover behavior for widgets in the viewport.

### **0.14.2** - *April 16, 2026*
  - feat: move loading indicators to the FilterBar and individual widgets.
  - fix: restore colors for table paths.
  - fix: correct widget autocomplete.

### **0.14.1** - *April 16, 2026*
  - feat: unify and polish the application UI.
  - feat: add a shared color picker for text widgets and widget groups.
  - feat: improve sidebar icon sizing and responsive dashboard actions.
  - fix: isolate navbar styling and limit chart hover work to visible charts.

### **0.14.0** - *April 6, 2026*
  - feat: make the Baker AI agent available globally.
  - feat: allow dashboards and monitors without an assigned source.
  - feat: add dedicated error pages.
  - feat: add a subtle navbar activity glow.

### **0.13.14** - *March 30, 2026*
  - feat: add admin management for projects and databases.

### **0.13.13** - *March 30, 2026*
  - feat: reposition navbar tooltips to avoid obstructing content.
  - fix: improve navbar styling and empty-data alerts.

### **0.13.12** - *March 29, 2026*
  - feat: support multi-series monitors and inline transponding.
  - fix: clean up navbar styling and icons.

### **0.13.11** - *March 27, 2026*
  - fix: correct GridStack reloads and widget-group sizing.
  - fix: prevent series suggestions from overflowing.
  - fix: apply additional widget-group stability fixes.

### **0.13.10** - *March 26, 2026*
  - feat: simplify widget editing inputs.
  - fix: improve series autocomplete, annotations, and tooltip behavior.
  - fix: correct sidebar stacking order.

### **0.13.9** - *March 25, 2026*
  - feat: add series sorting and prioritization.
  - feat: synchronize timeseries charts within widget groups.
  - fix: separate layout updates from widget changes.
  - fix: debounce widget rerenders while editing and improve series autocomplete.

### **0.13.8** - *March 19, 2026*
  - feat: introduce widget groups.
  - feat: allow widgets to be duplicated.
  - fix: preserve widget-group titles and prefer server-rendered widgets.

### **0.13.7** - *March 12, 2026*
  - feat: add inline transponders to widgets.
  - feat: integrate dashboard widgets into Baker and retire inline chat charts.
  - feat: improve Baker's AI tools.
  - fix: clean up transponders and correct the Trifle.Stats dependency reference.

### **0.13.6** - *March 8, 2026*
  - feat: move primary navigation to a sidebar.
  - feat: unify API access under organization tokens.
  - feat: restore the beginning-of-week setting.
  - fix: correct environment and workflow requirements.

### **0.13.5** - *March 4, 2026*
  - feat: add MinIO to the development Docker environment.

### **0.13.4** - *March 4, 2026*
  - feat: support SQLite database uploads.
  - feat: move uploaded SQLite databases to S3-compatible storage.

### **0.13.3** - *March 3, 2026*
  - fix: clean up GitHub Actions workflows.

### **0.13.2** - *March 2, 2026*
  - feat: add heatmap widgets.
  - feat: add bootstrap API endpoints for agentic onboarding.
  - feat: unify the widget modal and refactor widgets into composable components.
  - fix: restart database connections after configuration updates.

### **0.13.1** - *February 22, 2026*
  - feat: extend color palette support across widgets.

### **0.13.0** - *February 22, 2026*
  - feat: add multiple color palettes.
  - fix: refine color palette behavior and presentation.

### **0.12.9** - *February 19, 2026*
  - fix: query MongoProject metrics in a single batch.
  - fix: clean up admin icons.

### **0.12.8** - *February 18, 2026*
  - chore: release alignment tag (no additional app code changes vs `0.12.7`).

### **0.12.7** - *February 18, 2026*
  - feat: add MySQL support.
  - feat: unify transactional email templates.
  - docs: update the README and license.
  - fix: correct mail, Discord deployment, and test configuration issues.

### **0.12.6** - *February 13, 2026*
  - feat: improve navbar highlighting.
  - fix: project settings link.
  - feat: move retention mode setup to project creation flow.

### **0.12.5** - *February 12, 2026*
  - feat: add billing with Stripe subscriptions.
  - feat: add CI `.env` support and CI/devops configuration updates.
  - fix: apply follow-up fixes from testing and product feedback.
  - feat: clean up UI styling in billing-related screens.

### **0.12.4** - *February 10, 2026*
  - feat: update Trifle logo.
  - feat: update favicon assets.

### **0.12.3** - *February 5, 2026*
  - feat: support splat indicators with nested values.
  - feat: support scatter timeseries widgets.
  - feat: update Trifle.Stats dependency integration.
  - feat: improve Project Cluster setup.

### **0.12.2** - *February 5, 2026*
  - fix: convert timestamps to the correct project timezone in metrics API.

### **0.12.1** - *February 4, 2026*
  - feat: wire `TRIFLE_DB_ENCRYPTION_KEY` into deployment configuration.

### **0.12.0** - *February 4, 2026*
  - feat: support multiple Project Clusters.
  - feat: add database credential encryption plumbing for project clusters.
  - fix: seed script updates.

### **0.11.11** - *February 1, 2026*
  - feat: clean up series normalization.
  - fix: normalize string values in normalized responses.

### **0.11.10** - *February 1, 2026*
  - chore: release alignment tag (no additional app code changes vs `0.11.9`).

### **0.11.9** - *February 1, 2026*
  - feat: normalize API payloads.
  - feat: move CLI into separate `trifle-cli` repository.
  - fix: decimals handling and MongoProject driver parity.

### **0.11.8** - *January 17, 2026*
  - feat: API for Dashboards and Monitors
  - feat: improve content state between dashboard and form
  - feat: tweak CLI input validation

### **0.11.7** - *January 15, 2026*
  - fix: enable API for all deployments

### **0.11.6** - *January 15, 2026*
  - fix: Health endpoint change

### **0.11.5** - *January 15, 2026*
  - feat: move API to v1 and CLI with MCP
  - feat: Database with Tokens and API for metrics and transponders
  - fix: Copy public dashboard link
