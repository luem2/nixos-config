# Secretos

Este repo no debe contener secretos en texto plano.

## Hash no es lo mismo que cifrado

Un hash de contraseña no es la contraseña original, pero tampoco es un secreto
seguro para publicar. Si alguien obtiene el hash, puede intentar romperlo
offline probando muchas contraseñas hasta encontrar una coincidencia.

Un secreto cifrado con `sops-nix` o `agenix` es distinto: el repo guarda
ciphertext y sólo las claves privadas autorizadas pueden descifrarlo.

Regla práctica:

- no versionar contraseñas en texto plano;
- no publicar hashes de contraseñas en repos públicos;
- sí se pueden versionar secretos cifrados si están bien gestionados;
- las claves privadas que descifran secretos nunca van al repo.

## Política actual

Para esta PC personal:

- La contraseña del usuario `lucho` se define manualmente durante la instalación
  con `passwd`.
- La passphrase larga de LUKS se guarda fuera del repo, por ejemplo en
  Bitwarden.
- El PIN diario de TPM2 tampoco se versiona.
- SSH, VPN, tokens y credenciales quedan fuera del repo por ahora.

Esto es menos “100% declarativo”, pero es simple y seguro para la migración
inicial.

No se adopta `sops-nix` sólo para evitar ejecutar `passwd` durante la
instalación. Para que eso sea realmente automático también hay que llevar a la
ISO una clave privada `age` capaz de descifrar el secreto, respaldarla bien y
evitar que quede copiada donde no corresponde. Para una PC personal, ese extra
de bootstrap no compensa hasta que existan más secretos declarativos.

## Política recomendada a futuro

Cuando aparezca un secreto que sí convenga desplegar declarativamente, usar
`sops-nix`.

Motivos:

- maneja archivos estructurados como YAML/JSON/env;
- funciona bien con `age`;
- permite secretos de sistema y de Home Manager;
- tiene soporte para secretos necesarios antes de crear usuarios mediante
  `neededForUsers`;
- escala mejor si después este repo convive con un homelab NixOS.

`agenix` también es una buena opción y es más simple para archivos sueltos. Si
el único objetivo fuera guardar uno o dos secretos planos, sería suficiente. La
preferencia para este repo es `sops-nix` porque probablemente también se use en
el futuro servidor/homelab.

## Contraseña de usuario declarativa

Si más adelante se quiere declarar la contraseña del usuario, no usar:

```nix
users.users.lucho.hashedPassword = "...";
```

en un repo público.

Preferir un archivo externo:

```nix
users.users.lucho.hashedPasswordFile = config.sops.secrets.lucho-password.path;
```

Con `sops-nix`, ese secreto debe estar disponible antes de crear usuarios:

```nix
sops.secrets.lucho-password.neededForUsers = true;
```

Ese cambio queda pospuesto hasta adoptar `sops-nix` formalmente.

## Qué cosas sí cifrar

Candidatos razonables:

- hashes de contraseñas de usuarios si se quieren declarar;
- credenciales de servicios;
- tokens de APIs;
- claves privadas generadas para servicios automáticos;
- archivos `.env` que sean necesarios para servicios declarativos.

## Qué cosas no cifrar en este repo por ahora

- claves SSH privadas personales existentes;
- passphrase larga de LUKS;
- PIN de TPM2;
- password manager;
- sesiones de navegador.

Para claves SSH personales, suele ser mejor generar claves nuevas por propósito
y guardar sólo las claves públicas o la configuración no sensible.

## Referencias

- NixOS Wiki: User management
- NixOS Wiki: Comparison of secret managing schemes
- sops-nix
- agenix
