# Untime Retrospective

Author: Matt (Pante)
Status: NIL

## Summary

This is a retrospective on using Forui to build Untime, a time-budgeting app for Android and iOS. Its editorial design
system limit-tests Forui's theming capabilities.

It is broken into 3 sections:
* The good - What went well.
* The bad - What was okay and has areas for improvement.
* The ugly - What was downright awful.

## The Good

### Generated Theming

The theming/styling CLI is shockingly good when used with Claude/LLMs. Claude seems to better edit the generated inline
code rather than via the styling API. We should explore generating some form of instructions so that Claude is better 
able to use this by default. We should also investigate whether the CLI approach can be extended to the layout of widgets too.

## The Bad

### Style Deltas

Deltas sometimes confuse even us, the maintainers. Claude/LLMs fare particularly poorly with them. Consequently, one-off 
styling changes are difficult to implement. 

It does not help that "go to definition" takes users to the delta class, instead of the concrete style class, which lacks
the actual fields and associated documentation.

The lack of documentation on what each method parameter does does not help either.

Lastly, overriding variants isn't straightforward either partially because of the above.

### FVariants

`FVariants`, specifically when used to configure tappable variants, is still too verbose and frustrating to configure.
Call-sites require either a stateful widget (and wiring up the lifecycle methods) to reuse an `FVariants` across several
builds, or the `FVariants` needs to be re-created on each build method which is extremely wasteful. Mapping the different
states to colors/properties often becomes repetitive. For example, hovered and pressed colors almost always use
`colors.hover(...)` or `colors.secondary` while disabled always uses `colors.disable(...)`.

### Multiple Typographies and Extended Color Palettes

There currently is no proper support for design systems with multiple typographies, extended color palettes and/or misc.
styling. It is technically possible to create an `FThemeData` extension but separating the typographies and additional
colors from the base typography and colors is not good DX. In the short term, we should allow creating extensions on
`FTypography` and `FColors` to add additional typography and colors. In the long term, we should consider how
[augmentations](https://github.com/dart-lang/language/blob/main/working/augmentations/feature-specification.md) could
enable this.

### Misleading Documentation

The documentation for `FTypography` mentions "Defaults to x...". This is misleading when used with a custom design system
that customizes those values, as it is really easy to misunderstand "Defaults to X" as the default values for the custom
design system.

## The Ugly

### Icons

Lucide icons are used throughout Forui. As icons are hard coded across the entire package, they are needlessly tedious if
not impossible to change. We should introduce semantic icon tokens similar to `FColors` and `FStyle`.

### Picker

There is no fine-grained positioning of widgets between picker wheels.

### Card

The default layout of pure layout widgets, i.e. `FCard`, is pretty useless. The APIs are far too restrictive and
opinionated. Rather than trying to tune the layout using their styling, it is often easier to use the `raw` constructor
and pass in a custom layout. We should consider removing the default layout (and constructor), and generating the layout
inline in the user's project using the CLI similar to theming.

### Sheets

In Untime, sheets are typically used to show a form. To prevent users from accidentally dismissing the sheet and losing
their changes, a confirmation popover is shown before dismissal.

The sheet implementation is too low-level. This grants us complete control over the sheet's appearance but makes it
needlessly complex to implement a simple sheet. We should provide a higher level alternative that additionally implements
a background and rounded corners.

The sheet implementation lacks support for vetoing dismissals. This makes it impossible to intercept those dismissals to
show a confirmation popover and cancel the dismissal if the user decides to keep editing the form.

Lastly, we should consider integrating vetoing dismissals with Flutter's `Form`s as it is common to prevent dismissals
when the form is dirty or invalid. This requires several changes to the `Form` API available only in Flutter 3.44.0+.
