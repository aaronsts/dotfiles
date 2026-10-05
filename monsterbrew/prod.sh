_mb_dir="$HOME/.config/monsterbrew"

if [ ! -f "$_mb_dir/.env" ] || [ ! -f "$_mb_dir/do-ca.crt" ]; then
  echo "prod.sh: missing .env or do-ca.crt in $_mb_dir" >&2
  unset _mb_dir
  return 1
fi

set -a
. "$_mb_dir/.env"
set +a
export DATABASE_URL="${DB_PASSWORD}"

export DATABASE_CA_CERT="$(cat "$_mb_dir/do-ca.crt")"
unset _mb_dir

if [ -z "$DATABASE_URL" ]; then
  echo "prod.sh: .env did not set DATABASE_URL" >&2
  return 1
fi
