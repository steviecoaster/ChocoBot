---
external help file: ChocoBot-help.xml
Module Name: ChocoBot
online version:
schema: 2.0.0
---

# Add-ChocoBotSource

## SYNOPSIS

Adds a Chocolatey source to target computer(s).

## SYNTAX

```powershell
Add-ChocoBotSource [-FriendlyName] <String> [-Source] <String> [[-Computername] <String[]>] [-AllowSelfService]
 [-AdminOnly] [[-Priority] <Int32>] [[-Credential] <PSCredential>] [[-PFXCertificate] <String>]
 [[-CertificatePassword] <String>] [-BypassProxy] [<CommonParameters>]
```

## DESCRIPTION

Adds a Chocolatey source to target computer(s).

## EXAMPLES

### EXAMPLE 1

```powershell
Minimal source additon example
Add-ChocoSource -FriendlyName MyRepo -Source https://myrepository.com:8443/repository/MyRepo/ -Computername Finance01
```

### EXAMPLE 2

```powershell
Add an authenticated source
```

Add-ChocoBotSource -FriendlyName MyRepo -Source https://myrepository.com:8443/repository/MyRepo/ -Credential $credential -Computername Finance01

### EXAMPLE 3

```powershell
Add a self-service enabled source
```

Add-ChocoBotSource -FriendlyName MyRepo -Source https://myrepository.com:8443/repository/MyRepo/ -AllowSelfService -Computername Finance01

## PARAMETERS

### -FriendlyName

This is the human name of the source.
E.g.: chocolatey

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source

This is the path to the source.
E.g.: https://chocolatey.org/api/v2

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Computername

The computer(s) to add a source

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Target, Computer

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowSelfService

Enables Self Service mode for the source

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

### -AdminOnly

Allows only members of the local Administrators group to use the source

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

### -Priority

Set the priority of the source for retrieving packages

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

If authentication is required for the source, provide those credentials

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PFXCertificate

If a certificate is required for the source, add the path to the PFX certificate

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertificatePassword

If the PFX certificate has a password, enter it here

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BypassProxy

Instruct the source to bypass any system proxy configuration that may be applied

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
