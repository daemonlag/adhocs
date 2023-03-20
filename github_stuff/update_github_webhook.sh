repo_json=$(gh api /orgs/SpotHero/repos  --paginate | jq '[.[] | select(.archived == false)]' | jq -r '.[].name' )
id_list=()
secret="CHANGE_ME"
my_url="CHANGE_ME"
search_for="CHANGE_ME"

get_hook() {
  for i in $repo_json
  do
    hook_id=$(gh api /repos/spothero/${i}/hooks --paginate | jq  '[.[] | select( .config.url | contains('\"$search_for\"'))]' | jq -r '.[].url') # change spotbot  

    if [[ -n $hook_id  ]]; then
      id_list+=($hook_id)
    fi
  done
  echo ${id_list[@]}
}

get_hook

update_hook() {
  for url in ${id_list[@]}
  do
    curl -L \
      -X PATCH \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GH_TOKEN"\
      -H "X-GitHub-Api-Version: 2022-11-28" \
      $url \
      -d '{"active":true,"config":{"content_type":"json","secret":'\"$secret\"',"url":'\"$my_url\"'}}'
  done
}

update_hook
