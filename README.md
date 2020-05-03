# Summon

Summon is a MacOS status bar application that lets you configure custom hotkeys that bring applications to attention. The behaviour mimics navigating via `⌘-tab`, with the added benefit that Summon will launch the application if it's closed.
ahha
<p align="center">
  <img width="85%" src="./assets/demo.gif">
</p>

## Install

Checkout the <a href="https://github.com/rohaldb/Summon/releases/latest">latest release tab</a> to download Summon.


## Usage

Summon's preferences will open by default on launch. You can access them anytime through Summon's icon in the status bar.

![](./assets/statusbar.png)

To make a new binding, click on an application and enter a hotkey. You should enter the modifiers **before** you enter the key (see below).

## What is a hotkey

A hotkey is a combination of one or more modifier modifiers with a single key. A key is any key on the standard apple keyboard that isn't one of the modifiers.

**Permitted modifiers**:

 - command `⌘`
 - shift `⇧`
 - control `⌃`
 - option `⌥`

**Example hotkeys**:

 - command-J `⌘J`
 - control-option-4 `⌃⌥4`
 - control-shift-option-command-right arrow `⌃⇧⌥⌘→`

## Overriding Common Hotkeys

There is currently no mechanism that prevents a user from overriding common hotkeys such as Copy `⌘C`. Any hotkeys set in Summon will override system-wide (Copy) or application-specific (Chrome's New Tab) hotkeys.  

Unhappy with this? Me too! Feel free to raise a PR 😉
