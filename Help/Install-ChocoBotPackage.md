---
external help file: ChocoBot-help.xml
Module Name: ChocoBot
online version:
schema: 2.0.0
---

# Install-ChocoBotPackage

## SYNOPSIS

Installs a list of Chocolatey Packages on the target machine(s).

## SYNTAX

```powershell
Install-ChocoBotPackage [-Package] <String[]> [-Computername] <String[]> [[-Source] <String>] [-Force]
 [<CommonParameters>]
```

## DESCRIPTION

This function uses PSRemoting to install the provided list of Chocolatey packages on the target machine(s) specified in the chat message.

## EXAMPLES

### EXAMPLE 1

```powershell
Install-ChocoBotPackage -Package vlc -Computername Finance01
```

### EXAMPLE 2

```powershell
Install-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
```

## PARAMETERS

### -Package

The Chocolatey Package(s) to install.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Computername

The target computer(s) on which to perform the installation of the Chocolatey Package(s).

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

Will force the installation of the package to occur, even if it is already installed

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
