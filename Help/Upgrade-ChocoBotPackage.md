---
external help file: ChocoBot-help.xml
Module Name: ChocoBot
online version:
schema: 2.0.0
---

# Upgrade-ChocoBotPackage

## SYNOPSIS

Upgrades a list of Chocolatey Packages on the target machine(s).

## SYNTAX

```powershell
Upgrade-ChocoBotPackage [[-Package] <String[]>] [-Computername] <String[]> [[-Source] <String>] [-Force]
 [<CommonParameters>]
```

## DESCRIPTION

This function uses PSRemoting to Upgrade the provided list of Chocolatey packages on the target machine(s) specified in the chat message.

## EXAMPLES

### EXAMPLE 1

```powershell
Upgrade all Chocolatey packages on target computer(s)
```

UpgradeChocoBotPackage -Computername Finance01

### EXAMPLE 2

```powershell
Upgrade only the vlc package
```

Upgrade-ChocoBotPackage -Package vlc -Computername Finance01

### EXAMPLE 3

```powershell
Upgrade multiple packages on multiple machines
```

Upgrade-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)

## PARAMETERS

### -Package

The Chocolatey Package(s) to Upgrade.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -Computername

The target computer(s) on which to perform the Upgrade of the Chocolatey Package(s).

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Target, Computer

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source

If specified, will attempt to locate Chocolatey Packages from this location explicitly.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

Will force the upgrade of the package to occur, even if it is already Upgradeed

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
