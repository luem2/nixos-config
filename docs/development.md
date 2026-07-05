# Desarrollo con devShells

La idea en NixOS no es instalar todos los lenguajes y herramientas globalmente
para siempre. Lo global debe ser lo que usás todos los días en cualquier repo:
Git, editor, `direnv`, `just`, utilidades CLI y, temporalmente, algún runtime
mientras migrás.

Lo reproducible de verdad vive por proyecto.

## Global vs por proyecto

Regla práctica:

- Global: herramientas que usás en cualquier directorio y que no dependen del
  proyecto: `git`, editor, `just`, `direnv`, `nix`, `ripgrep`, `fd`, `eza`,
  `bat`, `zoxide`.
- Global temporal: lenguajes que todavía usás en muchos proyectos sin shell
  propio: Go, Rust, Python, `uv`, `sqlfluff`.
- Por proyecto: runtimes, compiladores, bases de datos, linters, formatters y
  CLIs atados a una versión concreta del proyecto.

Ejemplos de cosas que normalmente conviene mover a `devShell`:

- Node/Bun/PNPM/Yarn de un frontend.
- Go + `gopls` + `golangci-lint` de una API.
- Rust + `rust-analyzer` + `pkg-config` + librerías nativas.
- Python + `uv` + `ruff` + `sqlfluff` + dependencias del proyecto.
- PostgreSQL/Redis/SQLite tooling para una app puntual.
- Terraform, kubectl, cloud CLIs o herramientas de infraestructura de un repo
  específico.

Así evitás que tu sistema global se convierta en una mochila infinita de cosas
que “alguna vez usaste”.

## Flujo recomendado

En cada proyecto:

1. Crear un `flake.nix` del proyecto.
2. Crear un `.envrc` con:

   ```bash
   use flake
   ```

3. Ejecutar una sola vez:

   ```bash
   direnv allow
   ```

4. Entrar al directorio del proyecto. `direnv` carga automáticamente las
   herramientas declaradas.

También podés entrar manualmente sin `direnv`:

```bash
nix develop
```

Y salir con:

```bash
exit
```

Con `direnv`, el flujo es más cómodo: al entrar al directorio se carga el shell,
y al salir se descarga.

## Abbreviations, aliases y funciones Fish

En Fish, las abbreviations son expansores de texto. Por ejemplo, `gs` se expande
a `git status --short --branch` antes de ejecutar el comando. Eso tiene una
ventaja grande sobre un alias opaco: ves exactamente qué vas a correr antes de
apretar Enter.

Uso recomendado:

- `abbr`: comandos cortos y transparentes que querés ver expandidos:
  `gs`, `gcm`, `nix develop`, `docker compose up -d`.
- `alias`: compatibilidad simple cuando querés reemplazar un comando por otro.
  En este repo preferimos `abbr` salvo casos muy concretos.
- `function`: cuando hay lógica, validación de argumentos o cambio de
  directorio. Ejemplo: `mkcd`.

No conviene crear abbreviations globales para herramientas que sólo existen
dentro de un `devShell`. Si un proyecto necesita `pnpm`, `bun`, `terraform` o
una versión específica de `node`, declaralo en el shell del proyecto. Las
completions y binarios deben aparecer al entrar al proyecto, no vivir siempre en
tu sesión global.

## Comandos del repo NixOS desde cualquier lugar

El repo define una función Fish:

```fish
nixcfg <recipe>
```

Internamente ejecuta el `justfile` de `~/nixos-config` usando
`--justfile` y `--working-directory`, por lo que funciona desde cualquier
directorio.

Atajos disponibles:

```fish
nj   # nixcfg
njc  # nixcfg check
njb  # nixcfg build
njt  # nixcfg test
njs  # nixcfg switch
nju  # nixcfg update
```

Los atajos `j`, `jc`, `jb`, `jt`, `js` quedan para el `justfile` del directorio
actual. Así no rompemos proyectos que tengan su propio `justfile`.

## Función mkcd

`mkcd` crea un directorio y entra en él:

```fish
mkcd ~/workspace/nuevo-proyecto
```

Esto sí debe ser función y no abbreviation, porque necesita ejecutar dos pasos:
`mkdir -p` y luego `cd`.

## Go

Ejemplo mínimo:

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          go
          gopls
          golangci-lint
        ];
      };
    };
}
```

Después:

```bash
go run .
go test ./...
```

`go run` funciona normal porque `go` existe dentro del shell del proyecto.

## Python

Para proyectos personales simples, usar `uv` dentro del shell:

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          python3
          uv
          sqlfluff
        ];
      };
    };
}
```

Después:

```bash
uv run python main.py
sqlfluff lint .
```

## Rust

Ejemplo:

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          cargo
          rustc
          rust-analyzer
          rustfmt
          clippy
          pkg-config
          openssl
        ];
      };
    };
}
```

Después:

```bash
cargo run
cargo test
```

## Pruebas rápidas sin tocar el sistema

Para probar una herramienta una vez:

```bash
nix shell nixpkgs#go -c go version
nix shell nixpkgs#python3 -c python --version
nix run nixpkgs#clock-rs
```

Esto no agrega el paquete al perfil global.

## Pruebas técnicas y código ajeno

Para pruebas técnicas, challenges o repos que no controlás, Nix ayuda pero no es
una sandbox de seguridad completa.

Flujo razonable:

1. Clonar en un directorio separado.
2. Revisar archivos obvios antes de ejecutar nada:

   ```bash
   ls
   rg -n "curl|wget|bash|sh|sudo|rm -rf|ssh|token|password|postinstall|prepare" .
   ```

3. Si trae `flake.nix`, leerlo antes de `direnv allow`.
4. Preferir entrar manualmente primero:

   ```bash
   nix develop
   ```

5. Ejecutar tests/comandos específicos, no scripts enormes a ciegas.

6. Si el repo es sospechoso, usar aislamiento más fuerte: VM, contenedor,
   usuario separado o una máquina descartable.

Importante: `nix develop` controla dependencias, pero el código que ejecutás
adentro sigue teniendo acceso a tus archivos de usuario si lo corrés como tu
usuario normal. No reemplaza una VM/sandbox cuando hay desconfianza real.

## Política actual de este repo

Por ahora mantenemos Go, Rust y Python globales para no cortar el flujo diario
mientras migramos. El objetivo final es mover versiones específicas a cada
proyecto con `devShell` + `direnv`.

La virtualización local queda disponible en el perfil diario para poder aislar
proyectos o probar sistemas sin cambiar de configuración. Paquetes ocasionales
como Herdr o RustDesk quedan fuera y se usan sólo cuando hacen falta.
