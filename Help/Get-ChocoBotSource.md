---
external help file: ChocoBot-help.xml
Module Name: ChocoBot
online version:
schema: 2.0.0
---

# Get-ChocoBotSource

## SYNOPSIS

Retrieves all configured Chocolatey sources.

## SYNTAX

```powershell
Get-ChocoBotSource [-Computername] <String[]> [<CommonParameters>]
```

## DESCRIPTION

Retrieves the details all configured Chocolatey sources on provided computer name(s).

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ChocoBotSource -ComputerName PC1,PC2
```

## PARAMETERS

### -Computername

The computer(s) to query

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
