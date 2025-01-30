import std/[tables]
import ../../generator
import ../types

const
    urlObnoxiousCss: string = "https://tholman.com/obnoxious/obnoxious.css"
    obnoxiousCssElement: string = "animated"
const
    idPageLanguage: string = "page-language-variable"
    idSectionStartQuiz: string = "section-start-quiz"
    idSectionQuiz: string = "section-doing-quiz"
    idSectionComputing: string = "section-computing-results"
    idSectionShowingResults: string = "section-showing-results"

    idLoadingText: string = "loading-text"

    idButtonStartQuiz: string = "button-quiz-start"
    idButtonSubmit: string = "button-quiz-submit"
    idButtonRetryQuiz: string = "button-quiz-retry"

    idQuizQuestionPrefix: string = "quiz-question-nr-"
    idQuizQuestionYouTrustEverythingOnTheInternetSuffix: string = "nah-scratch-that-this-stays-on"

const strings = (
    meta: (
        title: toTable {
            enGB: "A.I. Health Diagnosis",
            deDE: "K.I. Gesundheitsdiagnose"
        },
        desc: toTable {
            enGB: "✨ Super-duper blazingly fast AI tool to diagnose ANY illness, better than your doctor!! 🚀",
            deDE: "✨ Ultra super-duper schnelles KI Tool, um JEGLICHE Erkrankung zu diagnostizieren, besser als Ihr Arzt!! 🚀"
        },
        file: toTable {
            enGB: "en.html",
            deDE: "de.html"
        }
    ),
    button: (
        start: toTable {
            enGB: "Start quiz",
            deDE: "Quiz starten"
        },
        submit: toTable {
            enGB: "Calculate",
            deDE: "Berechnen"
        },
        retry: toTable {
            enGB: "Retry quiz",
            deDE: "Quiz neustarten"
        }
    ),
    loading: toTable {
        enGB: "Computing...",
        deDE: "Berechnung läuft..."
    },
    diagnosis: (
        youHaveStart: toTable {
            enGB: "According to our 99.999%<small>*</small> accurate diagnoses, you suffer from",
            deDE: "Laut unserer 99,999%<small>*</small> korrekten Diagnose, leiden Sie unter"
        },
        youHaveEnd: toTable {
            enGB: "<small>* <u>If we are mistaken (impossible), then you just had bad luck!</u></small>",
            deDE: "<small>* <u>Falls wir falsch liegen sollten (unmöglich), dann haben Sie halt Pech gehabt!</u></small>"
        }
    ),
    question: (
        instructions: toTable {
            enGB: "Please submit the symptoms you are experiencing:",
            deDE: "Bitte kreuzen Sie die Symptome an, die Sie leiden lassen:"
        },
        additionWriting: toTable {
            enGB: "Feel free to elaborate on your symptoms, this will help our AI model to accurately diagnose you:",
            deDE: "Sie können weitere Symptome hier erläutern. Dies wird unserem KI Modell helfen, Sie besser zu diagnostizieren:"
        },
        youTrustEverythingOnTheInternet: toTable {
            enGB: "You trust everything on the internet.",
            deDE: "Sie glauben Alles, was im Internet steht."
        },
        list: [
            toTable {
                enGB: "Sniffles",
                deDE: "Schnupfen"
            },
            toTable {
                enGB: "Coughing",
                deDE: "Husten"
            },
            toTable {
                enGB: "Dizziness",
                deDE: "Schwindel"
            },
            toTable {
                enGB: "Headache",
                deDE: "Kopfschmerzen"
            },
            toTable {
                enGB: "Back pain",
                deDE: "Rückenschmerzen"
            },
            toTable {
                enGB: "Muscle pain",
                deDE: "Muskelschmerzen"
            },
            toTable {
                enGB: "Dry mouth",
                deDE: "Trockener Mund"
            },
            toTable {
                enGB: "Light sensitivity",
                deDE: "Lichtempfindlichkeit"
            },
            toTable {
                enGB: "Trembling",
                deDE: "Zittern"
            }
        ]
    )
)

var
    htmlEN: HtmlDocument
    htmlDE: HtmlDocument
proc `->`(htmlTarget: var HtmlDocument, htmlSource: HtmlDocument) =
    htmlTarget = htmlSource
    htmlTarget.file = "game/ai-doctor-diagnosis/" & $strings.meta.file


proc newQuestion(id, text: string, inputAttrs: seq[HtmlElementAttribute] = @[]): HtmlElement =
    result = `div`(
        label(id, "").add(
            input("checkbox", id).add(inputAttrs),
            rawText text
        )
    )

for language in Language:
    setTranslationTarget(language)
    var html: HtmlDocument = newHtmlPage(
        $strings.meta.title,
        $strings.meta.desc,
        $strings.meta.file,
        includeInMenuBar = false
    )
    html.setStylesheet(newCssStyleSheet(urlObnoxiousCss))
    html.addToHead(
        importScript("/javascript/game/blazingly-fast-health-diagnosis.js").addattr("defer")
    )

    html.add( # Wtf is this monstrosity??
        `var`(
            case language:
            of enGB: "enGB"
            of deDE: "deDE"
        ).setId(idPageLanguage).addStyle(
            "display" := "none"
        )
    )

    var questions: seq[HtmlElement] = @[]
    for questionCount, question in strings.question.list:
        let id: string = idQuizQuestionPrefix & $questionCount
        questions.add newQuestion(id, $question)

    questions.add newQuestion(
        idQuizQuestionYouTrustEverythingOnTheInternetSuffix,
        $strings.question.youTrustEverythingOnTheInternet,
        @[attr("checked")]
    )

    html.add(
        # Static header:
        header(
            h1($strings.meta.title),
            p($strings.meta.desc)
        ),

        # Semi-dynamic content:
        article(
            # Start quiz screen:
            `div`(
                button($strings.button.start, "startQuiz();").setId(idButtonStartQuiz)
            ).setId(idSectionStartQuiz).addStyle("display" := "initial"),

            # Quiz screen:
            `div`(
                fieldset(
                    @[legend($strings.question.instructions)] & questions
                ),
                button($strings.button.submit, "submitQuiz();").setId(idButtonSubmit)
            ).setId(idSectionQuiz).addStyle("display" := "none"),

            # Computing screen:
            `div`(
                h2($strings.loading).setId(idLoadingText).setClass(obnoxiousCssElement),
            ).setId(idSectionComputing).addStyle("display" := "none"),

            # Results display screen:
            `div`(
                button($strings.button.retry, "restartQuiz();").setId(idButtonRetryQuiz).setId(idButtonRetryQuiz)
            ).setId(idSectionShowingResults).addStyle("display" := "none")
        )
    )

    case language:
    of enGB: htmlEN -> html
    of deDE: htmlDE -> html

incl htmlEN
incl htmlDE
