# Noctalia: cambios en vivo y configuración declarativa

La configuración permanente de Noctalia vive en:

```text
modules/home/desktop.nix
```

Home Manager genera:

```text
~/.config/noctalia/config.toml
```

Ese archivo apunta al Nix store y no se edita a mano.

## Abrir la configuración visual

Desde Niri:

```text
Win+,
```

O desde terminal:

```bash
noctalia msg settings-open
```

La UI de Noctalia permite probar cambios en vivo. Cuando guardás algo desde la
UI, Noctalia lo escribe como override mutable en:

```text
~/.local/state/noctalia/settings.toml
```

Ese archivo es estado local. Sirve para experimentar, pero no se versiona.

## Ver la configuración activa

Ver sólo overrides locales:

```bash
sed -n '1,220p' ~/.local/state/noctalia/settings.toml
```

Ver configuración efectiva/mezclada:

```bash
noctalia config export merged
```

Ver configuración completa:

```bash
noctalia config export full
```

Validar:

```bash
noctalia config validate
```

Recargar Noctalia:

```bash
noctalia msg config-reload
```

Reiniciar el servicio de usuario:

```bash
systemctl --user restart noctalia
```

## Cómo copiar un cambio al repo

La conversión es directa:

```toml
[bar.main]
thickness = 40
padding = 8
start = ["launcher", "workspaces"]
```

se vuelve:

```nix
programs.noctalia.settings.bar.main = {
  thickness = 40;
  padding = 8;
  start = [
    "launcher"
    "workspaces"
  ];
};
```

Otro ejemplo:

```toml
[widget.media]
max_length = 220
hide_when_no_media = true
```

se vuelve:

```nix
programs.noctalia.settings.widget.media = {
  max_length = 220;
  hide_when_no_media = true;
};
```

Regla práctica:

- tabla TOML `[a.b.c]` → atributo Nix `a.b.c = { ... };`
- strings TOML → strings Nix;
- arrays TOML → listas Nix;
- booleanos TOML → `true`/`false`;
- números TOML → números Nix;
- claves con `_` se mantienen igual.

## Clima y ubicación

Noctalia usa una única configuración de ubicación para clima, night light y
modo de tema automático.

Para una PC personal con repo público, lo más privado y reproducible es usar
una ciudad amplia o coordenadas aproximadas:

```nix
programs.noctalia.settings = {
  weather = {
    enabled = true;
    refresh_minutes = 30;
    unit = "celsius";
    effects = true;
  };
  location = {
    auto_locate = false;
    address = "Ciudad, País";
  };
};
```

Si preferís que detecte dónde estás cuando viajás:

```nix
programs.noctalia.settings.location.auto_locate = true;
```

Ese modo consulta geolocalización por IP mediante el servicio de Noctalia, así
que conviene usarlo sólo si esa comodidad vale la pena.

## Flujo recomendado

1. Probar en la UI de Noctalia.
2. Mirar qué apareció en `~/.local/state/noctalia/settings.toml`.
3. Copiar sólo el cambio útil a `modules/home/desktop.nix`.
4. Ejecutar `just check`.
5. Aplicar con `just test` o `just switch`.
6. Reiniciar Noctalia si no se actualiza sola.

Una vez copiado al repo, conviene limpiar el override local correspondiente
para que no tape la configuración declarativa.
