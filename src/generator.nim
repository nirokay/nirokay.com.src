import std/[tables, times, strutils]
import websitegenerator
export websitegenerator except newHtmlDocument, newDocument, writeFile
import resources

proc timeStamp(): string =
    result = now().format("yyyy-MM-dd --- hh-mm-ss")

var
    menuBarPages*: OrderedTable[string, string]
    htmlPages*: seq[HtmlDocument] ## Global variable for all html pages to be generated
    cssSheets*: seq[CssStyleSheet] ## Global variable for all css stylesheets to be generated


proc incl*(html: HtmlDocument) = htmlPages.add html ## Includes an HTML page into `htmlPages`
proc incl*(css: CssStyleSheet) = cssSheets.add css ## Includes a CSS stylesheet into `cssSheets`


proc og(property, content: string): HtmlElement =
    result = "meta"[
        "property" => "og:" & property,
        "content" => content
    ]

proc newHtmlPage*(title, description, path: string, includeInMenuBar: bool = true, cssPath: string = ""): HtmlDocument =
    result = newHtmlDocument(path)
    # Html header stuff:
    result.addToHead(
        comment("HTML and CSS is generated using https://github.com/nirokay/websitegenerator "),
        comment("Generated: " & timeStamp() & " "),
        charset("utf-8"),
        "meta"[
            "name" => "viewport",
            "content" => "width=device-width, initial-scale=1"
        ],
        title(title),
        og("title", title),
        og("description", description),
        icon(pathImages & "/favicon.gif", imageGif, "32x32"),
        "link"[
            "rel" => "stylesheet",
            "href" => "/styles.css",
            "title" => "Absolute path to global css"
        ],
        "link"[
            "rel" => "stylesheet",
            "href" => "styles.css",
            "title" => "Relative path to global css" # Used for local debugging/test builds
        ],
        importScript("/javascript/menu-bar.js")
    )
    if includeInMenuBar: menuBarPages[title] = path

    if cssPath != "":
        result.addToHead(
            "link"[
                "rel" => "stylesheet",
                "href" => "/" & cssPath # GLobal stylesheet (will not work when testing out locally :/)
            ]
        )

proc getMenuBar*(): HtmlElement =
    var options: seq[HtmlElement] = @[
        option("--ignore--", "-- Menu --").addattr("selected")
    ]
    for title, path in menuBarPages:
        options.add option(path, title)
    result = select("Menu bar", "id-menu-bar", options).add(
        attr("onchange", "changeToSelectedPage();"),
        attr("id", "id-menu-bar")
    )

proc generatePage*(page: HtmlDocument) =
    ## Alternative for `writeFile(html)`, adding some final touches before generating the document
    var html: HtmlDocument = page
    html.body = @[
        `div`(
            `div`(
                `div`(page.body).setClass("div-centering-inner")
            ).setClass("div-centering-middle")
        ).setClass("div-centering-outer"),
        `div`(
            getMenuBar()
        ).setClass("div-menu-bar-container"),
    ]
    html.writeFile()

proc generateCss*(stylesheet: CssStyleSheet) =
    ## Alternative for `writeFile(css)`, adding some final touches before generating the stylesheet
    var css: CssStyleSheet = newCssStyleSheet(stylesheet.file)
    css.add newCssClass(".metadata",
        ["generated-at", timeStamp()]
    )
    css.elements = css.elements & stylesheet.elements
    css.writeFile()
