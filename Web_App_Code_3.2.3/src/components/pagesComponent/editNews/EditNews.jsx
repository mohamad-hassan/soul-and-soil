'use client'
import React, { useEffect, useState } from 'react'
import Layout from '../../layout/Layout'
import Breadcrumb from '../../breadcrumb/Breadcrumb'
import { currentLangCode, translate } from '@/utils/helpers'
import { selectcreateNewsCurrentLanguage, selectManageNews } from '@/components/store/reducers/createNewsReducer'
import toast from 'react-hot-toast'
import { useSelector } from 'react-redux'
import { useRouter } from 'next/router'
import { setNewsApi } from '@/utils/api/api'
import { languagesListSelector } from '@/components/store/reducers/languageReducer'
import EditNewsForm from './EditNewsForm'

const EditNews = () => {

    const currLangCode = currentLangCode();
    const router = useRouter()

    const manageNews = useSelector(selectManageNews)
    const languagesList = useSelector(languagesListSelector)

    const [url, setUrl] = useState(manageNews && manageNews?.content_value)

    const createNewsLanguage = useSelector(selectcreateNewsCurrentLanguage)

    const [step, setStep] = useState(1)

    const matchingObject = languagesList.find(obj => obj.id === manageNews?.language_id)

    // Helper function to safely create a Date object
    const safelyCreateDate = (dateStr) => {
        if (!dateStr || dateStr === '0000-00-00' || dateStr === '') return null;

        try {
            const date = new Date(dateStr);
            return isNaN(date.getTime()) ? null : date;
        } catch (error) {
            console.error("Invalid date format:", dateStr);
            return null;
        }
    }

    const [defaultValue, setDefaultValue] = useState({
        defaultTitle: manageNews && manageNews?.title,
        defaultMetatitle: manageNews && manageNews?.meta_title,
        defaultMetaDescription: manageNews && manageNews?.meta_description,
        defaultMetaKeyword: manageNews && manageNews?.meta_keyword,
        defaultSlug: manageNews && manageNews?.slug,
        categorydefault: manageNews && manageNews?.category?.category_name,
        standardType: manageNews && manageNews?.content_type,
        contentValue: manageNews && manageNews?.content_value,
        tagValue: manageNews && manageNews?.tag_name ? manageNews && manageNews?.tag_name?.split(',') : null,
        dateValue: safelyCreateDate(manageNews && manageNews?.show_till),
        publishDateValue: safelyCreateDate(manageNews && manageNews?.published_date),
        imagedefault: manageNews && manageNews?.image,
        defaultImageData: manageNews && manageNews?.image,
        languageId: manageNews && manageNews?.language_id,
        categoryID: manageNews && manageNews?.category_id,
        tagsid: manageNews && manageNews?.tag_id,
        contentType: manageNews && manageNews?.content_type,
        multipleImage: manageNews && manageNews?.images,
        subcategorydefault: manageNews && manageNews?.sub_category?.subcategory_name,
        subcategoryID: manageNews && manageNews?.subcategory_id,
        languageName: matchingObject?.language,
        descriptionValue: manageNews && manageNews?.description,
        defaultLocationId: manageNews && manageNews?.location_id,
        defaultLocation: manageNews && manageNews?.location?.location_name
    })

    const [images, setImages] = useState([])


    const [videoData, setVideoData] = useState(manageNews && manageNews?.content_value)

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
    const handleChangeContent = value => {
        setDefaultValue({ ...defaultValue, descriptionValue: value })
    }

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
            toast.error(translate('YouTubeVideosNotSupported'))
            return false
        }
    }

    const dateConfirmation = () => {
        const showTillDate = defaultValue.dateValue;
        const publishDate = defaultValue.publishDateValue;

        if (publishDate && showTillDate && publishDate > showTillDate) {
            toast.error(translate('dateConfirmation'));
            return; // Prevent form submission
        }
    }

    // Add a utility function at the top of your component to clean URLs
    const cleanUrlString = (urlString) => {
        if (typeof urlString !== 'string') return '';
        return urlString.replace(/^@/, '');
    };

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
        if (!defaultValue.publishDateValue) {
            toast.error(translate("publishDateRequired"))
            return
        }

        // Clean and set URL
        if (typeof url === 'string') {
            const cleanedUrl = cleanUrlString(url);
            setUrl(cleanedUrl);
        }

        // Set the URL value based on content type
        if (defaultValue.contentType === 'video_upload') {
            setUrl(videoData);
        } else if (defaultValue.contentType === 'video_youtube' || defaultValue.contentType === 'video_other') {
            // Ensure URL is clean when passing to next step
            setDefaultValue(prev => ({
                ...prev,
                contentValue: cleanUrlString(url)
            }));
        }

        //url selector validation
        const cleanUrl = typeof url === 'string' ? url.replace(/^@/, '') : url

        if (defaultValue.contentType === 'video_youtube') {
            const isYouTubeVideo = validateVideoUrl(cleanUrl)
            if (!isYouTubeVideo) {
                // URL is not a YouTube video
                toast.error(translate('urlIsNotYouTubeVideo'))
                return
            }
        } else if (defaultValue.contentType === 'video_other') {
            const isYouTubeVideo = validateVideoUrl(cleanUrl)
            if (isYouTubeVideo) {
                // YouTube videos are not supported for "video_other" content type
                toast.error(translate('YouTubeVideosNotSupported'))
                return
            }
        }

        dateConfirmation()

        const slugValue = await slugConverter()

        // Format dates safely
        let formattedShowTill = "";
        let formattedPublishedDate = "";

        try {
            // Safely format show_till date if it exists and is valid
            if (defaultValue.dateValue && defaultValue.dateValue instanceof Date && !isNaN(defaultValue.dateValue)) {
                formattedShowTill = new Date(defaultValue.dateValue.getTime() - defaultValue.dateValue.getTimezoneOffset() * 60000)
                    .toISOString()
                    .split('T')[0];
            }

            // Safely format published_date if it exists and is valid
            if (defaultValue.publishDateValue && defaultValue.publishDateValue instanceof Date && !isNaN(defaultValue.publishDateValue)) {
                formattedPublishedDate = new Date(defaultValue.publishDateValue.getTime() - defaultValue.publishDateValue.getTimezoneOffset() * 60000)
                    .toISOString()
                    .split('T')[0];
            }
        } catch (dateError) {
            console.error("Error formatting dates:", dateError);
            // Continue with empty dates rather than failing the whole submission
        }

        try {
            const response = await setNewsApi.setNews({
                action_type: 2,
                category_id: defaultValue.categoryID,
                subcategory_id: defaultValue.subcategoryID,
                tag_id: defaultValue.tagsid,
                title: defaultValue.defaultTitle,
                meta_title: defaultValue.defaultMetatitle,
                meta_description: defaultValue.defaultMetaDescription,
                meta_keyword: defaultValue.defaultMetaKeyword,
                slug: slugValue,
                content_type: defaultValue.contentType,
                content_data: url,
                description: defaultValue.descriptionValue,
                image: defaultValue.imagedefault,
                ofile: images,
                show_till: formattedShowTill,
                language_id: defaultValue.languageId,
                location_id: defaultValue.defaultLocationId ? defaultValue.defaultLocationId : null,
                published_date: formattedPublishedDate,
            });
            if (response?.data?.error) {
                toast.error(response?.data?.message)
            }
            else {
                toast.success(translate('newsUpdatedSuccessfully'))
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
                <Breadcrumb secondElement={translate('editNewsLbl')} />

                <div className='commonBg'>
                    <section className="createNews container pt-2 md:pt-3 py-8 md:py-12">
                        <EditNewsForm setStep={setStep} defaultValue={defaultValue} setDefaultValue={setDefaultValue} images={images} setImages={setImages} createNewsLanguage={createNewsLanguage} manageNews={manageNews} url={url} setUrl={setUrl} matchingObject={matchingObject} cleanUrlString={cleanUrlString} setVideoData={setVideoData}
                            handleChangeContent={handleChangeContent} finalSubmit={finalSubmit} dateConfirmation={dateConfirmation}
                        />
                    </section>
                </div>
            </>
        </Layout>
    )
}

export default EditNews