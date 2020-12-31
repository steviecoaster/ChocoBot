# ChocoBot - The PoshBot Chocolatey Plugin

## :construction: THIS PROJECT IS IN DEVELOPMENT. It is functionally useless at the minute. This README will be updated once something useful is available.

Do you use Slack? Teams? Discord? Do you partake in [ChatOps](https://www.pagerduty.com/blog/what-is-chatops/)? If you've answered yes, or you'd _like_ to do those things, this is another tool in your toolbelt!

This plug-in allows you to execute choco commands on target systems directly from your enterprise messaging platform!

## Cool things you can do

- Install Chocolatey Packages
- Uninstall Chocolatey Packages
- Upgrade Chocolatey Packages
- List available Chocolatey Packages for installation
- Configure Chocolatey Sources

## Installation

Steps: 

1. Clone this repository
2. cd into newly cloned repository directory
3. Run ./build.ps1 -Build
4. Run ./build.ps1 -Deploy
5. Copy ChocoBot folder to $PSModulePath

## Hooking up PoshBot

1. Follow QuickStart Guide available [here](https://poshbot.readthedocs.io/en/latest/guides/quickstart/).
2. Run `!install-plugin ChocoBot` from within your Messaging platform once you have PoshBot added

## Usage

### Installing a package

From within your messaging platform, once you have the Bot running and the plug-in installed use one of the following:

`!install -Package $packagename -Source $Source -Computername $computername`

or, with fully qualified commands

!Install-ChocoBotPackage -Package $package -Source $source -Computername $computername`

### Uninstalling a package

From within your messaging platform, once you have the Bot running and the plug-in installed use one of the following:

`!uninstall -Package $packagename -Computername $computername`

or, with fully qualified commands

!Uninstall-ChocoBotPackage -Package $package -Computername $computername`

### Upgrading packages

From within your messaging platform, once you have the Bot running and the plug-in installed use one of the following:

```powershell
#upgrade all packages
!upgrade -Computername $computername
```

or,

```powershell
#upgrade specific package
!upgrade -Package $package -Computername $computername
```

or, with fully-qualified commands

```powershell
#upgrade all packages with Fully-Qualified command name
!Upgrade-ChocoBotPackage -Computername $computername`
```

### Getting packages

```powershell
#Retrieve available packages from source on target computer
!listpackages -Source $source -Computername $computername
```

```powershell
#List installed Chocolatey packages
!listpackages -LocalOnly -Computername $computername
```

```powershell
#Fully-Qualified Command
!Get-ChocoBotPackage -Source $source -Computername $computername
```

## Help

Help is available via a chat message! For example, for help with installing packages, execute the following:

```powershell
!help choco:install
```

Online help is also available in the docs [here](https://github.com/steviecoaster/ChocoBot/blob/main/Help).
