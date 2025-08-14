'use client'
import React, { useState } from 'react'
import Layout from '../../layout/Layout'
import Breadcrumb from '../../breadcrumb/Breadcrumb'
import { currentLangCode, translate } from '@/utils/helpers'
import { selectcreateNewsCurrentLanguage } from '@/components/store/reducers/createNewsReducer'
import toast from 'react-hot-toast'
import { useSelector } from 'react-redux'
import { useRouter } from 'next/router'
import { setNewsApi } from '@/utils/api/api'
import AiCreateNewsApi from '@/gemini-api/AiCreateNewsApi'
import CreateNewsForm from './CreateNewsForm'

const CreateNews = () => {

    const currLangCode = currentLangCode();

    const router = useRouter()

    const createNewsLanguage = useSelector(selectcreateNewsCurrentLanguage);

    const [defaultValue, setDefaultValue] = useState({
        defaultTitle: null,
        defaultMetatitle: '',
        defaultMetaDescription: '',
        defaultMetaKeyword: '',
        defaultSlug: null,
        defaultLanguage: null,
        defaultLanguageCode: null,
        defaultCategory: null,
        defaultCategoryID: null,
        defaultSubCategory: null,
        defaultSubCategoryID: null,
        defaultSelector: null,
        defaultType: null,
        defaultTag: null,
        defaultTagName: null,
        defaultContent: null,
        defaultStartDate: null,
        defaultPublishDate: null,
        defaultUrl: null,
        defaultVideoData: null,
        defaultImageData: null,
        defaultImagefile: null,
        defaultLocation: null
    })

    const [images, setImages] = useState([])
    // slug
    const slugConverter = () => {
        let slug = defaultValue.defaultSlug
        slug = slug.replace(/[^a-zA-Z0-9-]/g, '-')
        slug = slug.replace(/-+/g, '-')
        slug = slug.replace(/^-+/, '')
        slug = slug.replace(/-+$/, '')
        return slug
    }


    // step 2 state and function 

    const [content, setContent] = useState('')
    const handleChangeContent = value => {
        setContent(value)
    }

    const [isGeneratingContent, setIsGeneratingContent] = useState(false)
    const [aiPrompt, setAiPrompt] = useState('')

    // AI content generation function
    const generateAIContent = async () => {
        if (!aiPrompt) {
            toast.error(translate('pleaseEnterPromptForAI'))
            return
        }

        setIsGeneratingContent(true)
        try {
            // Add formatting instructions to the prompt
            const formattedPrompt = `${aiPrompt} Please format the response in proper paragraphs and highlight important sentences with bold text using HTML tags (<b></b> or <strong></strong>).`

            const data = await AiCreateNewsApi.generateContent({
                prompt: formattedPrompt,
                title: defaultValue.defaultTitle,
                category: defaultValue.defaultCategory,
                language: createNewsLanguage.name,
                languageCode: createNewsLanguage.code
            })

            if (data.content) {
                // ReactQuill will interpret HTML formatting correctly
                // handleChangeContent(content ? content + '\n\n' + data.content : data.content)
                handleChangeContent(data.content)
                toast.success(translate('aiContentGeneratedSuccessfully'))
                setAiPrompt('')
            }
        } catch (error) {
            console.error('Error generating AI content:', error)
            toast.error(translate('failedToGenerateAIContent'))
        } finally {
            setIsGeneratingContent(false)
        }
    }

    const [videoSet, setVideoSet] = useState(!defaultValue.defaultVideoData)

    // validate url
    const validateVideoUrl = urlData => {
        // eslint-disable-next-line
        const videoUrlPattern =
            /^(?:http(?:s)?:\/\/)?(?:www\.)?(?:m\.)?(?:youtu\.be\/|youtube\.com\/((?:watch)\?(?:.*&)?v(?:i)?=|(?:embed|v|vi|user)\/))([^\?&\"'>]{11})/
        const shortsUrlPattern = /^(https?:\/\/)?(www\.)?(youtube\.com)\/(shorts)/
        if (videoUrlPattern.test(urlData)) {
            // URL is a YouTube video
            return true
        } else if (shortsUrlPattern.test(urlData)) {
            // URL is a YouTube Shorts video
            toast.error(translate('youtubeShortsNotSupported'))
            return false
        }
    }

    // final submit data
    const finalSubmit = async e => {

        e.preventDefault()


        if (!defaultValue.defaultTitle) {
            toast.error(translate("titlerequired"))
            return
        }

        if (!defaultValue.defaultSlug) {
            toast.error(translate("slugrequired"))
            return
        }
        if (!defaultValue.defaultLanguage) {
            toast.error(translate("selectlanguage"))
            return
        }
        if (!defaultValue.defaultCategory) {
            toast.error(translate("selectcategory"))
            return
        }

        if (!defaultValue.defaultType) {
            toast.error(translate("contentTyperequired"))
            return
        }
        if (!defaultValue.defaultPublishDate) {
            toast.error(translate("publishDateRequired"))
            return
        }


        if (defaultValue.defaultType === 'video_upload') {
            setDefaultValue({ ...defaultValue, defaultUrl: defaultValue.defaultVideoData })
        }
        //category selector validation
        if (defaultValue.defaultCategoryID === '') {
            toast.error(translate('plzSelCatLbl'))
            return
        }

        //url selector validation
        if (defaultValue.defaultType === 'video_youtube') {
            const isYouTubeVideo = validateVideoUrl(defaultValue.defaultUrl)
            if (!isYouTubeVideo) {
                // URL is not a YouTube video
                toast.error(translate('urlIsNotYouTubeVideo'))
                return
            }
        } else if (defaultValue.defaultType === 'video_other') {
            const isYouTubeVideo = validateVideoUrl(defaultValue.defaultUrl)
            if (isYouTubeVideo) {
                // YouTube videos are not supported for "video_other" content type
                toast.error(translate('YouTubeVideosNotSupported'))
                return
            }
        }

        if (defaultValue.defaultType === 'video_upload' && !videoSet) {
            // toast.error(translate('uploadMainImageLbl'))
            toast.error(translate('plzUploadVideoLbl'))
            return
        }
        // main image validation
        if (defaultValue.defaultImageData === null) {
            toast.error(translate('uploadMainImageLbl'))
            return
        }


        const slugValue = await slugConverter()

        try {
            const response = await setNewsApi.setNews({
                action_type: 1,
                category_id: defaultValue.defaultCategoryID,
                subcategory_id: defaultValue.defaultSubCategoryID,
                tag_id: defaultValue.defaultTag,
                title: defaultValue.defaultTitle,
                meta_title: defaultValue.defaultMetatitle,
                meta_description: defaultValue.defaultMetaDescription,
                meta_keyword: defaultValue.defaultMetaKeyword,
                slug: slugValue,
                content_type: defaultValue.defaultType,
                content_data: defaultValue.defaultUrl,
                description: content,
                image: defaultValue.defaultImagefile,
                ofile: images,
                show_till: defaultValue.defaultStartDate ? new Date(defaultValue.defaultStartDate.getTime() - defaultValue.defaultStartDate.getTimezoneOffset() * 60000)
                    .toISOString()
                    .split('T')[0] : '',
                published_date: new Date(defaultValue.defaultPublishDate.getTime() - defaultValue.defaultPublishDate.getTimezoneOffset() * 60000)
                    .toISOString()
                    .split('T')[0],
                language_id: createNewsLanguage.id,
                location_id: defaultValue.defaultLocation ? defaultValue.defaultLocation : null,
            })
            if (response?.data?.error) {
                if (response?.data?.message == 'The slug is already in use. Please choose another. response?.data?.message') {
                    toast.error(translate('slugUsedAlready'))
                } else {
                    toast.error(response?.data?.message)
                }
            }
            else {
                toast.success(translate('newsCreatedSuccessfully'))
                router.push(`/${currLangCode}/manage-news`)
            }
        } catch (error) {
            console.log(error)
            toast.error(error)
        }
    }

    return (
        <Layout>
            <>
                <Breadcrumb secondElement={translate('createNewsLbl')} />

                <div className='commonBg'>
                    <section className="createNews container pt-2 md:pt-3 py-8 md:py-12">

                        <CreateNewsForm defaultValue={defaultValue} setDefaultValue={setDefaultValue} images={images} setImages={setImages} createNewsLanguage={createNewsLanguage}
                            content={content} handleChangeContent={handleChangeContent} finalSubmit={finalSubmit} aiPrompt={aiPrompt} setAiPrompt={setAiPrompt} isGeneratingContent={isGeneratingContent} generateAIContent={generateAIContent} setVideoSet={setVideoSet}
                        />

                    </section>
                </div>
            </>
        </Layout>
    )
}

export default CreateNews