--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import            Data.Monoid (mappend)
import            Hakyll
import            Text.Pandoc.Highlighting        (Style, haddock, styleToCss)
import            Text.Pandoc.Options             (ReaderOptions (..), WriterOptions (..))
import            Text.Pandoc.Templates
import            Text.Pandoc.Class
import            Text.Blaze.Html                 (toHtml, toValue, (!))
import            Text.Blaze.Html.Renderer.String (renderHtml)
import            Text.Blaze.Html5.Attributes     (href, class_)
import            Data.Text                       (pack)
import            Data.Either                     (fromRight)
import qualified  Text.Blaze.Html5                as H
--------------------------------------------------------------------------------

config = defaultConfiguration
  { destinationDirectory = "docs"
  }

main :: IO ()
main = hakyllWith config $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.md", "notes.md", "links.md"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler'
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler'
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match "notes/*" $ do
        route $ setExtension "html"
        compile $ pandocCompilerWith defaultHakyllReaderOptions withTOC
            >>= loadAndApplyTemplate "templates/note.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Posts"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler
    
    create ["css/syntax.css"] $ do
        route idRoute
        compile $ do
            makeItem $ styleToCss pandocCodeStyle

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%Y-%m-%d" `mappend`
    defaultContext

pandocCodeStyle :: Style
pandocCodeStyle = haddock

pandocCompiler' :: Compiler (Item String)
pandocCompiler' =
  pandocCompilerWith
    defaultHakyllReaderOptions
    defaultHakyllWriterOptions
      { writerHighlightStyle   = Just pandocCodeStyle
      }

withTOC :: WriterOptions
withTOC = defaultHakyllWriterOptions
        { writerTableOfContents = True
        , writerNumberSections  = True
        , writerTOCDepth        = 4
        , writerTemplate        =
         let
            toc = "$toc$" :: String
            body = "$body$" :: String
            html = pack . renderHtml $ do
                     H.div ! class_ "toc" $
                        toHtml toc
                     toHtml body
            template  =  fromRight mempty <$> compileTemplate "" html
            runPureWithDefaultPartials = runPure . runWithDefaultPartials
            eitherToMaybe = either (const Nothing) Just
         in
            eitherToMaybe (runPureWithDefaultPartials template)
        }
