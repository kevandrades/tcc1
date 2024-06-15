courts_states <- c(
  "TRT1" = "RJ",
  "TRT2" = "SP",
  "TRT3" = "MG",
  "TRT4" = "RS",
  "TRT5" = "BA",
  "TRT6" = "PE",
  "TRT7" = "CE",
  "TRT8" = "AP e PA",
  "TRT9" = "PR",
  "TRT10" = "DF e TO",
  "TRT11" = "AM e RR",
  "TRT12" = "SC",
  "TRT13" = "PB",
  "TRT14" = "AC e RO",
  "TRT15" = "SP",
  "TRT16" = "MA",
  "TRT17" = "ES",
  "TRT18" = "GO",
  "TRT19" = "AL",
  "TRT20" = "SE",
  "TRT21" = "RN",
  "TRT22" = "PI",
  "TRT23" = "MT",
  "TRT24" = "MS"
)

select_columns <- c(
  "sigla_tribunal", "sigla_grau",
  "id_orgao_julgador", "id_formato",
  "ultimo_dia", "procedimento",
  "originario", "ramo_justica",
  "ind1", "ind2", "ind4", "ind5",
  "ind6a", "ind8a", "ind9", "ind10",
  "ind11", "ind13a", "ind13b",
  "ind24", "ind25", "ind26",
  "ind16_dias", "ind16_proc"
)

explicative_labels <- c(
  "ind5" = "Tramitando",
  "ind4" = "Suspensos",
  "ind6a" = "Conclusos",
  "ind8a" = "Julgamentos",
  "ind9" = "Despachos",
  "ind10" = "Decisões",
  "ind11" = "Audiências",
  "ind13a" = "Liminares deferidas",
  "ind13b" = "Liminares indeferidas",
  "ind24" = "Casos Novos de Recurso Interno",
  "ind25" = "Recurso Interno Pendente",
  "ind26" = "Recurso Interno Julgado"
)

explicative_columns <- names(explicative_labels)

fmt_explicative_labels <- c(
  "ind5" = "Tramitando",
  "ind4" = "Suspensos e
Sobrestados",
  "ind6a" = "Conclusos",
  "ind8a" = "Julgamentos",
  "ind9" = "Despachos",
  "ind10" = "Decisões",
  "ind11" = "Audiências",
  "ind13a" = "Liminares
deferidas",
  "ind13b" = "Liminares
  indeferidas",
  "ind24" = "Casos Novos de
Recurso Interno",
  "ind25" = "Recurso Interno
Pendente",
  "ind26" = "Recurso Interno
Julgado"
)

reverse_explicative_labels <- as.list(setNames(names(fmt_explicative_labels), fmt_explicative_labels))

procedimentos_output <- c(
  "Conhecimento não criminal" = "Conhecimento\nnão criminal",
  "Execução fiscal" = "Execução\nfiscal",
  "Execução judicial" = "Execução\njudicial",
  "Execução penal não privativa de liberdade" ="Execução penal\nnão privativa
  de liberdade",
  "Outros" = "Outros",
  "Execução extrajudicial não fiscal" = "Execução\nextrajudicial\nnão fiscal",
  "Pré-processual" = "Pré-processual",
  "Conhecimento criminal" = "Conhecimento
  criminal"
)