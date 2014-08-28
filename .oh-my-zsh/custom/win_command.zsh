function QAQ_test () {
  if [[ $3 =~ ^dig ]] ; then
    print QAQ
    throw OWO
  fi
}

#add-zsh-hook preexec QAQ_test


function win() {
  env PATH=$WIN_PATH bash -c "$(printf "%q " "$@")" | iconv -f big5 -t utf-8
}
