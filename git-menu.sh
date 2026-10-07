#!/usr/bin/env bash
# ============================================================
#  git-menu.sh - Menú interactivo de Git para la terminal
#  Uso: ejecútalo dentro de la carpeta de tu repositorio
#       ./git-menu.sh
# ============================================================

# ---------- Colores ----------
ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
AZUL='\033[0;34m'
CIAN='\033[0;36m'
NEGRITA='\033[1m'
NC='\033[0m'

# ---------- Verificaciones ----------
if ! command -v git >/dev/null 2>&1; then
    echo -e "${ROJO}Git no está instalado.${NC} Instálalo con: sudo apt install git"
    exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${ROJO}Esta carpeta no es un repositorio de Git.${NC}"
    echo "Entra a la carpeta de tu repo (cd ruta/del/repo) y vuelve a ejecutar el script."
    exit 1
fi

# ---------- Utilidades ----------
pausa() {
    echo
    read -rp "Presiona Enter para continuar..." _
}

mensaje_ok()    { echo -e "${VERDE}✔ $1${NC}"; }
mensaje_error() { echo -e "${ROJO}✘ $1${NC}"; }
mensaje_info()  { echo -e "${CIAN}➜ $1${NC}"; }

confirmar() {
    # confirmar "¿Seguro?" -> devuelve 0 si responde s/S
    read -rp "$1 [s/N]: " resp
    [[ "$resp" =~ ^[sS]$ ]]
}

rama_actual() {
    git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD
}

tiene_upstream() {
    git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1
}

encabezado() {
    clear
    local repo rama cambios
    repo=$(basename "$(git rev-parse --show-toplevel)")
    rama=$(rama_actual)
    cambios=$(git status --porcelain | wc -l)

    echo -e "${NEGRITA}${AZUL}╔══════════════════════════════════════════╗${NC}"
    echo -e "${NEGRITA}${AZUL}║            MENÚ DE GIT                   ║${NC}"
    echo -e "${NEGRITA}${AZUL}╚══════════════════════════════════════════╝${NC}"
    echo -e " Repo:   ${NEGRITA}$repo${NC}"
    echo -e " Rama:   ${VERDE}$rama${NC}"
    if [ "$cambios" -gt 0 ]; then
        echo -e " Estado: ${AMARILLO}$cambios archivo(s) con cambios${NC}"
    else
        echo -e " Estado: ${VERDE}limpio${NC}"
    fi
    echo
}

# ---------- Acciones básicas ----------
ver_estado() {
    echo
    git status
    pausa
}

ver_diff() {
    echo
    echo "1) Cambios sin agregar (working directory)"
    echo "2) Cambios ya agregados (staged)"
    read -rp "Elige [1-2]: " o
    case $o in
        1) git diff ;;
        2) git diff --staged ;;
        *) mensaje_error "Opción no válida" ;;
    esac
    pausa
}

agregar() {
    echo
    git status -s
    echo
    echo "1) Agregar TODO        (git add -A)"
    echo "2) Agregar archivos específicos"
    read -rp "Elige [1-2]: " o
    case $o in
        1)
            git add -A && mensaje_ok "Todos los cambios agregados"
            ;;
        2)
            read -rp "Archivos (separados por espacio): " archivos
            if [ -n "$archivos" ]; then
                # shellcheck disable=SC2086
                git add $archivos && mensaje_ok "Archivos agregados"
            else
                mensaje_info "Cancelado"
            fi
            ;;
        *) mensaje_error "Opción no válida" ;;
    esac
    pausa
}

hacer_commit() {
    echo
    # Si no hay nada en staging pero sí cambios, ofrecer agregar todo
    if git diff --cached --quiet; then
        if [ -n "$(git status --porcelain)" ]; then
            mensaje_info "No hay archivos en staging."
            if confirmar "¿Agregar todos los cambios (git add -A)?"; then
                git add -A
            else
                mensaje_info "Cancelado"
                pausa
                return
            fi
        else
            mensaje_info "No hay nada para hacer commit."
            pausa
            return
        fi
    fi

    echo "Archivos que irán en el commit:"
    git diff --cached --stat
    echo
    read -rp "Mensaje del commit: " msg
    if [ -z "$msg" ]; then
        mensaje_error "El mensaje no puede estar vacío. Cancelado."
    else
        git commit -m "$msg" && mensaje_ok "Commit realizado"
    fi
    pausa
}

hacer_push() {
    echo
    local rama
    rama=$(rama_actual)
    if tiene_upstream; then
        mensaje_info "Enviando '$rama' al remoto..."
        git push && mensaje_ok "Push completado"
    else
        mensaje_info "La rama '$rama' aún no tiene rama remota asociada."
        if confirmar "¿Crear y asociar con 'origin/$rama'?"; then
            git push -u origin "$rama" && mensaje_ok "Push completado"
        else
            mensaje_info "Cancelado"
        fi
    fi
    pausa
}

hacer_pull() {
    echo
    mensaje_info "Descargando cambios del remoto..."
    git pull && mensaje_ok "Pull completado"
    pausa
}

hacer_fetch() {
    echo
    mensaje_info "Consultando el remoto (sin modificar tus archivos)..."
    git fetch --all --prune && mensaje_ok "Fetch completado"
    pausa
}

ver_log() {
    echo
    git --no-pager log --oneline --graph --decorate --color=always -n 20
    pausa
}

# ---------- Ramas ----------
menu_ramas() {
    while true; do
        encabezado
        echo -e "${NEGRITA}RAMAS${NC}"
        echo " 1) Listar ramas"
        echo " 2) Crear rama nueva"
        echo " 3) Cambiar de rama"
        echo " 4) Crear y cambiar a rama nueva"
        echo " 5) Fusionar (merge) una rama en la actual"
        echo " 6) Eliminar una rama local"
        echo " 0) Volver"
        echo
        read -rp "Elige una opción: " o
        case $o in
            1) echo; git branch -a -vv; pausa ;;
            2)
                read -rp "Nombre de la nueva rama: " n
                [ -n "$n" ] && git branch "$n" && mensaje_ok "Rama '$n' creada"
                pausa ;;
            3)
                echo; git branch; echo
                read -rp "Cambiar a la rama: " n
                [ -n "$n" ] && git switch "$n"
                pausa ;;
            4)
                read -rp "Nombre de la nueva rama: " n
                [ -n "$n" ] && git switch -c "$n" && mensaje_ok "Ahora estás en '$n'"
                pausa ;;
            5)
                echo; git branch; echo
                read -rp "Rama a fusionar en '$(rama_actual)': " n
                [ -n "$n" ] && git merge "$n"
                pausa ;;
            6)
                echo; git branch; echo
                read -rp "Rama a eliminar: " n
                if [ -n "$n" ] && confirmar "¿Eliminar la rama '$n'?"; then
                    git branch -d "$n" || {
                        mensaje_info "Si la rama tiene cambios sin fusionar, Git no la borra con -d."
                        confirmar "¿Forzar eliminación (-D)?" && git branch -D "$n"
                    }
                fi
                pausa ;;
            0) return ;;
            *) mensaje_error "Opción no válida"; sleep 1 ;;
        esac
    done
}

# ---------- Stash ----------
menu_stash() {
    while true; do
        encabezado
        echo -e "${NEGRITA}STASH (guardar cambios temporalmente)${NC}"
        echo " 1) Guardar cambios en el stash"
        echo " 2) Ver lista de stashes"
        echo " 3) Recuperar el último stash (pop)"
        echo " 4) Borrar todos los stashes"
        echo " 0) Volver"
        echo
        read -rp "Elige una opción: " o
        case $o in
            1)
                read -rp "Descripción (opcional): " d
                if [ -n "$d" ]; then git stash push -u -m "$d"; else git stash push -u; fi
                pausa ;;
            2) echo; git stash list; pausa ;;
            3) echo; git stash pop; pausa ;;
            4)
                confirmar "¿Borrar TODOS los stashes? No se puede deshacer" && git stash clear && mensaje_ok "Stashes borrados"
                pausa ;;
            0) return ;;
            *) mensaje_error "Opción no válida"; sleep 1 ;;
        esac
    done
}

# ---------- Deshacer ----------
menu_deshacer() {
    while true; do
        encabezado
        echo -e "${NEGRITA}DESHACER${NC}"
        echo " 1) Sacar archivos de staging (unstage)"
        echo " 2) Deshacer el último commit (conserva los cambios)"
        echo " 3) Modificar el mensaje del último commit (amend)"
        echo " 4) Descartar cambios de un archivo ${ROJO}(irreversible)${NC}"
        echo " 5) Descartar TODOS los cambios ${ROJO}(irreversible)${NC}"
        echo " 0) Volver"
        echo
        read -rp "Elige una opción: " o
        case $o in
            1)
                echo; git status -s; echo
                read -rp "Archivo (vacío = todos): " f
                if [ -n "$f" ]; then git restore --staged -- "$f"; else git restore --staged .; fi
                mensaje_ok "Hecho"
                pausa ;;
            2)
                if confirmar "¿Deshacer el último commit manteniendo los cambios?"; then
                    git reset --soft HEAD~1 && mensaje_ok "Último commit deshecho"
                fi
                pausa ;;
            3)
                read -rp "Nuevo mensaje: " m
                [ -n "$m" ] && git commit --amend -m "$m" && mensaje_ok "Mensaje actualizado"
                echo -e "${AMARILLO}Aviso:${NC} si ya hiciste push de ese commit, tendrás que forzar el push."
                pausa ;;
            4)
                echo; git status -s; echo
                read -rp "Archivo a descartar: " f
                if [ -n "$f" ] && confirmar "¿Perder los cambios de '$f' para siempre?"; then
                    git restore -- "$f" && mensaje_ok "Cambios descartados"
                fi
                pausa ;;
            5)
                if confirmar "¿Descartar TODOS los cambios sin commit? No se puede deshacer"; then
                    git reset --hard HEAD && mensaje_ok "Todo descartado"
                    confirmar "¿Borrar también los archivos nuevos sin seguimiento (git clean)?" && git clean -fd
                fi
                pausa ;;
            0) return ;;
            *) mensaje_error "Opción no válida"; sleep 1 ;;
        esac
    done
}

# ---------- Remotos ----------
menu_remotos() {
    echo
    git remote -v
    echo
    echo "1) Agregar remoto"
    echo "2) Cambiar URL de un remoto"
    echo "0) Volver"
    read -rp "Elige una opción: " o
    case $o in
        1)
            read -rp "Nombre (ej. origin): " n
            read -rp "URL: " u
            [ -n "$n" ] && [ -n "$u" ] && git remote add "$n" "$u" && mensaje_ok "Remoto agregado"
            ;;
        2)
            read -rp "Nombre del remoto: " n
            read -rp "Nueva URL: " u
            [ -n "$n" ] && [ -n "$u" ] && git remote set-url "$n" "$u" && mensaje_ok "URL actualizada"
            ;;
    esac
    pausa
}

# ---------- Menú principal ----------
while true; do
    encabezado
    echo -e "${NEGRITA}BÁSICO${NC}"
    echo "  1) Ver estado             (status)"
    echo "  2) Ver cambios            (diff)"
    echo "  3) Agregar archivos       (add)"
    echo "  4) Hacer commit           (commit)"
    echo "  5) Subir cambios          (push)"
    echo "  6) Descargar cambios      (pull)"
    echo "  7) Consultar remoto       (fetch)"
    echo "  8) Ver historial          (log)"
    echo
    echo -e "${NEGRITA}AVANZADO${NC}"
    echo "  9) Ramas                  (branch / switch / merge)"
    echo " 10) Stash                  (guardar cambios temporalmente)"
    echo " 11) Deshacer               (restore / reset / amend)"
    echo " 12) Remotos                (remote)"
    echo
    echo "  0) Salir"
    echo
    read -rp "Elige una opción: " opcion

    case $opcion in
        1)  ver_estado ;;
        2)  ver_diff ;;
        3)  agregar ;;
        4)  hacer_commit ;;
        5)  hacer_push ;;
        6)  hacer_pull ;;
        7)  hacer_fetch ;;
        8)  ver_log ;;
        9)  menu_ramas ;;
        10) menu_stash ;;
        11) menu_deshacer ;;
        12) menu_remotos ;;
        0)  echo "¡Hasta luego!"; exit 0 ;;
        *)  mensaje_error "Opción no válida"; sleep 1 ;;
    esac
done
