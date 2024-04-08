COURT_STATES = {
    "TRT1": "RJ",
    "TRT2": "SP",
    "TRT3": "MG",
    "TRT4": "RS",
    "TRT5": "BA",
    "TRT6": "PE",
    "TRT7": "CE",
    "TRT8": "AP e PA",
    "TRT9": "PR",
    "TRT10": "DF e TO",
    "TRT11": "AM e RR",
    "TRT12": "SC",
    "TRT13": "PB",
    "TRT14": "AC e RO",
    "TRT15": "SP",
    "TRT16": "MA",
    "TRT17": "ES",
    "TRT18": "GO",
    "TRT19": "AL",
    "TRT20": "SE",
    "TRT21": "RN",
    "TRT22": "PI",
    "TRT23": "MT",
    "TRT24": "MS"
}

FT_SELECT_COLUMNS = (
    "sigla_tribunal", "sigla_grau",
    "id_orgao_julgador", "id_formato",
    "ultimo_dia", "procedimento",
    "originario", "ramo_justica",
    "ind1", "ind2", "ind4", "ind5",
    "ind6a", "ind8a", "ind9", "ind10",
    "ind11", "ind13a", "ind13b",
    "ind24", "ind25", "ind26",
    "ind16_dias", "ind16_proc",
    "ind18_dias", "ind18_proc"
)

EXP_LABELS = {
    "ind5": "Tramitando",
    "ind4": "Suspensos e Sobrestados",
    "ind6a": "Conclusos",
    "ind8a": "Julgamentos",
    "ind9": "Despachos",
    "ind10": "Decisões",
    "ind11": "Audiências",
    "ind13a": "Liminares deferidas",
    "ind13b": "Liminares indeferidas",
    "ind24": "Casos Novos de Rec. Interno",
    "ind25": "Rec. Interno Pendente",
    "ind26": "Rec. Interno Julgado"
}

NUM_EXP_COLUMNS = tuple(EXP_LABELS.keys())

CAT_EXP_COLUMNS = 'sigla_grau_G2', 'procedimento_1', 'procedimento_2', 'procedimento_6', 'procedimento_7', 'formato_Físico'

EXP_COLUMNS = NUM_EXP_COLUMNS + CAT_EXP_COLUMNS

FORMATTED_EXP_LABELS = {
    "ind5": "Tramitando",
    "ind4": "Suspensos e\nSobrestados",
    "ind6a": "Conclusos",
    "ind8a": "Julgamentos",
    "ind9": "Despachos",
    "ind10": "Decisões",
    "ind11": "Audiências",
    "ind13a": "Liminares\ndeferidas",
    "ind13b": "Liminares\nindeferidas",
    "ind24": "Casos Novos de\nRec. Interno",
    "ind25": "Rec. Interno\nPendente",
    "ind26": "Rec. Interno\nJulgado"
}

REV_EXP_LABELS = dict(zip(FORMATTED_EXP_LABELS.values(), FORMATTED_EXP_LABELS.values()))

PROCEDIMENTOS_OUTPUT = {
    "Conhecimento não criminal": "Conhecimento\nnão criminal",
    "Execução fiscal": "Execução\nfiscal",
    "Execução judicial": "Execução\njudicial",
    "Execução penal não privativa de liberdade":"Execução penal\nnão privativa\nde liberdade",
    "Execução extrajudicial não fiscal": "Execução\nextrajudicial\nnão fiscal",
    "Pré-processual": "Pré-processual",
    "Conhecimento criminal": "Conhecimento\ncriminal",
    "Outros": "Outros",
}

PROCEDIMENTOS_ID = {
    "Conhecimento criminal": 1,
    "Conhecimento não criminal": 2,
    "Execução extrajudicial não fiscal": 3,
    "Execução fiscal": 4,
    "Execução judicial": 5,
    "Pré-processual": 6,
    "Outros": 7
}

GRAU_ID = {"G1": 1, "G2": 2}

SIGLA_GRAU = {"G1": "Primeiro Grau", "G2": "Segundo Grau"}

ID_FORMATO = {1: "Eletrônico", 2: "Físico"}

ORIGINARIO = {"Originário": "Sim", "Recursal": "Não"}