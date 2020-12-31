---
external help file: ChocoBot-help.xml
Module Name: ChocoBot
online version:
schema: 2.0.0
---

# Get-ChocoBotPackage

## SYNOPSIS

Retrieves packages available on a source per Computername

## SYNTAX

```powershell
Get-ChocoBotPackage [[-Source] <String>] [-LocalOnly] [-Computername] <String[]> [[-Package] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Retrieves packages available on a source per Computername

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ChocoBotPackage -Source MyRepo -Computername Finance01
```

### EXAMPLE 2

```powershell
Get-ChocoBotPackage -Source https://myserver:8443/repository/MyRepo/ -Computername Finance01
```

### EXAMPLE 3

```powershell
Get-ChocoBotPackage -Source MyRepo -Computername Finance01 -Package lob-app
```

## PARAMETERS

### -Source

The source to query

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocalOnly

Return installed Chocolatey Package information

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Installed

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Computername

The computer name(s) to run against

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Computer, Target

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Package

Optionally the specific package to query

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
