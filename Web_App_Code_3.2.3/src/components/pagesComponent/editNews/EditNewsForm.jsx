'use client'
import React, { useState, useEffect } from 'react'
import DatePicker from 'react-datepicker'
import { MdEditCalendar } from 'react-icons/md';
import { getDirection, translate } from '@/utils/helpers';
import { deleteImagesApi, getCategoriesApi, getLocationApi, getSubCategoryByCategoryIdApi, getTagsApi } from '@/utils/api/api';
import { currentLanguageSelector, languagesListSelector } from '@/components/store/reducers/languageReducer';
import { useSelector } from 'react-redux';
import {
    Select,
    SelectContent,
    SelectGroup,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select"
import { setCreateNewsCurrentLanguage } from '@/components/store/reducers/createNewsReducer';
import { settingsSelector } from '@/components/store/reducers/settingsReducer';
import toast from 'react-hot-toast';
import TagSelect from './TagSelect';
import { addDays } from 'date-fns'
import { IoIosCloseCircle } from 'react-icons/io';
import Dropzone from 'react-dropzone'
import { AiFillPicture, AiOutlineUpload } from 'react-icons/ai';
import { Swiper, SwiperSlide } from 'swiper/react';
import VideoPlayerModal from '@/components/commonComponents/videoplayer/VideoPlayerModal';

// Import Swiper styles
import 'swiper/css';
import 'swiper/css/free-mode';
import 'swiper/css/pagination';
import MetaInfoToolTip from '../createNews/MetaInfoToolTip';
import ReactQuill from 'react-quill';

const EditNewsForm = ({ defaultValue, setDefaultValue, images, setImages, matchingObject, manageNews, url, setUrl, handleChangeContent, finalSubmit, dateConfirmation, cleanUrlString, setVideoData }) => {

    const settingsData = useSelector(settingsSelector)
    const languagesList = useSelector(languagesListSelector)

    const currentLanguage = useSelector(currentLanguageSelector)


    const [categories, setCategories] = useState([])
    const [subCategories, setSubCategories] = useState([])
    const [locationsData, setLocationsData] = useState([])
    const [tagsData, setTagsData] = useState([])

    const [showCategory, setShowCategory] = useState(false)
    const [showSubCategory, setShowSubCategory] = useState(false)
    const [showUrl, setShowURl] = useState(false)
    const [otherUrl, setOtherUrl] = useState(false)
    const [videoUrl, setVideoUrl] = useState(null)


    // category api call
    const getCategories = async () => {
        try {
            const { data } = await getCategoriesApi.getCategories({
                offset: '',
                limit: '70',
                language_id: defaultValue.languageId
            })
            setCategories(data.data)
        } catch (error) {
            if (error === 'No Data Found') {
                <span>{translate('nodatafound')}</span>
            }
        }
    }

    // sub category api call
    const getSubCategories = async (id) => {
        if (id) {
            try {
                const res = await getSubCategoryByCategoryIdApi.getSubCategoryByCategoryId({
                    category_id: id,
                    language_id: currentLanguage?.id
                })
                if (res.data?.data?.length === 0) {
                    setSubCategories([]);
                    setShowSubCategory(false)
                    return
                }
                setSubCategories(res.data?.data)
                setShowSubCategory(true)
            } catch (error) {
                if (error === 'No Data Found') {
                    setShowSubCategory(false)
                    setSubCategories("")
                }
            }
        }
        else {
            try {
                const res = await getSubCategoryByCategoryIdApi.getSubCategoryByCategoryId({
                    category_id: manageNews?.category_id,
                    language_id: currentLanguage?.id
                })
                if (res.data?.error) {
                    setShowSubCategory(false)
                }
                else {
                    setShowSubCategory(true)
                    setSubCategories(res.data?.data)
                }
            } catch (error) {
                if (error === 'No Data Found') {
                    setShowSubCategory(false)
                    setSubCategories("")
                }
            }
        }
    }

    // location api call
    const getLocation = async () => {
        try {
            const { data } = await getLocationApi.getLocation({ limit: 10000 })
            setLocationsData(data?.data)
        } catch (error) {
            console.log(error)
        }
    }

    // tags api call
    const getTags = async () => {
        try {
            const { data } = await getTagsApi.getTags({ language_id: defaultValue.languageId })
            setTagsData(data?.data)
        } catch (error) {
            console.log(error)
        }
    }

    // load language data to reducer
    const languageSelector = value => {
        setShowCategory(true)
        // cateRef.current = null;
        const selectedData = JSON.parse(value)
        // setLanguage(selectedData.id)
        setDefaultValue(prevValue => ({
            ...prevValue,
            languageId: selectedData.id,
            languageName: selectedData.language,
            categorydefault: null
        }))
    }


    // change category
    const categorySelector = (value) => {
        const selectedCategory = JSON.parse(value);
        if (!selectedCategory || typeof selectedCategory !== 'object') {
            console.error('Invalid selection value:', value);
            return;
        }
        setDefaultValue({ ...defaultValue, categorydefault: selectedCategory?.category_name, categoryID: selectedCategory?.id })
        setSubCategories([]);
        getSubCategories(selectedCategory?.id)
    }

    // change sub-category
    const subcategorySelector = (value) => {
        const selectedSubCategory = JSON.parse(value);
        setDefaultValue({ ...defaultValue, subcategoryID: selectedSubCategory?.id, subcategorydefault: selectedSubCategory?.subcategory_name })
    }

    useEffect(() => {
        setDefaultValue({ ...defaultValue, subcategoryID: null, subcategorydefault: null })
    }, [defaultValue?.categoryID])

    useEffect(() => {
        getSubCategories()
        // console.log(defaultValue?.languageId)
    }, [defaultValue?.languageId])

    // Update the useEffect to properly clean and set the URL
    useEffect(() => {
        if (matchingObject) {
            setShowCategory(true)
            setDefaultValue({ ...defaultValue, languageId: matchingObject.id, languageName: matchingObject?.language })
        }

        // Initialize UI based on content type
        const contentType = defaultValue.contentType || manageNews?.content_type;

        if (contentType === 'standard_post') {
            setDefaultValue({ ...defaultValue, standardType: translate('stdPostLbl'), contentType: 'standard_post' })
            setShowURl(false)
            setVideoUrl(false)
            setOtherUrl(false)
            setUrl(null)
        } else if (contentType === 'video_youtube') {
            setDefaultValue({ ...defaultValue, standardType: translate('videoYoutubeLbl'), contentType: 'video_youtube' })
            setShowURl(true)
            setVideoUrl(false)
            setOtherUrl(false)

            // Clean the URL value
            const contentValue = defaultValue.contentValue || manageNews?.content_value || '';
            const cleanedUrl = cleanUrlString(contentValue);
            setUrl(cleanedUrl);
        } else if (contentType === 'video_other') {
            setDefaultValue({ ...defaultValue, standardType: translate('videoOtherUrlLbl'), contentType: 'video_other' })
            setShowURl(false)
            setOtherUrl(true)
            setVideoUrl(false)

            // Clean the URL value
            const contentValue = defaultValue.contentValue || manageNews?.content_value || '';
            const cleanedUrl = cleanUrlString(contentValue);
            setUrl(cleanedUrl);
        } else if (contentType === 'video_upload') {
            setDefaultValue({ ...defaultValue, standardType: translate('videoUploadLbl'), contentType: 'video_upload' })
            setShowURl(false)
            setVideoUrl(true)
            setOtherUrl(false)
            // Initialize video data from manageNews if available
            setVideoData(manageNews?.content_value)
        } else {
            setShowURl(false)
            setVideoUrl(false)
            setOtherUrl(false)
        }
    }, [])

    // create standard post
    const standardPost = [
        {
            id: 1,
            type: translate('stdPostLbl'),
            name: 'standard_post',
            param: 'empty'
        },
        {
            id: 2,
            type: translate('videoYoutubeLbl'),
            name: 'video_youtube',
            param: 'url'
        },
        {
            id: 3,
            type: translate('videoOtherUrlLbl'),
            name: 'video_other',
            param: 'url'
        },
        {
            id: 4,
            type: translate('videoUploadLbl'),
            name: 'video_upload',
            param: 'file'
        }
    ];

    // video selector
    const handleVideo = e => {
        if (e.target.files[0] && !e.target.files[0].type.includes('video')) {
            toast.error(translate('pleaseSelectVideoFormat'))
            return true
        }
        setDefaultValue({ ...defaultValue, defaultVideoData: e.target.files[0] })
        setVideoData(e.target.files[0])
    }

    // Modify the select post type function to properly clear video data when changing types
    const postSelector = value => {
        // const selectedType = JSON.parse(value);
        // Safely parse the JSON value
        let selectedType;
        try {
            selectedType = JSON.parse(value);
        } catch (error) {
            console.error('Invalid JSON value:', value);
            return;
        }
        if (!selectedType || typeof selectedType !== 'object') {
            console.error('Invalid selection value:', value);
            return;
        }
        // Find the selected option in the standardPost array
        const selectedOption = standardPost.find(elem => elem.id === selectedType?.id)

        if (selectedOption) {
            const contentType = selectedOption.name

            // Immediately clear the URL if switching away from video_upload
            if (defaultValue.contentType === 'video_upload' && contentType !== 'video_upload') {
                setUrl(''); // Clear URL immediately to prevent [object File] 
            }

            if (contentType !== defaultValue.contentType) {
                // Reset content value when changing types
                if (defaultValue.contentType === 'video_upload' && contentType !== 'video_upload') {
                    // Clear video data when switching away from video_upload
                    setVideoData(null);
                    setDefaultValue(prev => ({
                        ...prev,
                        contentValue: '',
                        // Make sure to clear any file reference
                        defaultVideoData: null
                    }));
                } else {
                    setDefaultValue(prev => ({ ...prev, contentValue: '' }));
                }
            }

            if (contentType === 'standard_post') {
                setDefaultValue({
                    ...defaultValue,
                    standardType: translate('stdPostLbl'),
                    contentType: 'standard_post',
                    // Make sure to explicitly clear any content values
                    contentValue: null,
                    defaultVideoData: null
                })
                setShowURl(false)
                setVideoUrl(false)
                setOtherUrl(false)
                setUrl(null)
            } else if (contentType === 'video_youtube') {
                setDefaultValue({
                    ...defaultValue,
                    standardType: translate('videoYoutubeLbl'),
                    contentType: 'video_youtube',
                    // Clear video data
                    defaultVideoData: null
                })
                setShowURl(true)
                setVideoUrl(false)
                setOtherUrl(false)
            } else if (contentType === 'video_other') {
                setDefaultValue({
                    ...defaultValue,
                    standardType: translate('videoOtherUrlLbl'),
                    contentType: 'video_other',
                    // Clear video data
                    defaultVideoData: null
                })
                setShowURl(false)
                setOtherUrl(true)
                setVideoUrl(false)
            } else if (contentType === 'video_upload') {
                setDefaultValue({
                    ...defaultValue,
                    standardType: translate('videoUploadLbl'),
                    contentType: 'video_upload'
                })
                setShowURl(false)
                setVideoUrl(true)
                setOtherUrl(false)
            } else {
                setShowURl(false)
                setVideoUrl(false)
                setOtherUrl(false)
            }
        }
    }

    useEffect(() => {
        getLocation()
    }, [])

    useEffect(() => {
        if (defaultValue.languageId) {
            getCategories()
            getTags()
        }
    }, [defaultValue.languageId])

    useEffect(() => {
        if (languagesList?.length < 2) {
            setShowCategory(true)
            setDefaultValue(prevValue => ({
                ...prevValue,
                languageId: settingsData?.data?.default_language?.id,
                languageName: settingsData?.data?.default_language?.language,
                // categorydefault: null
            }))
            setShowSubCategory(false)
        }

    }, [languagesList])


    // tag
    const handleTagChange = values => {
        let tagIds = values.map(value => {
            const selectedTag = tagsData.find(elem => elem.tag_name === value)
            if (selectedTag) {
                return selectedTag.id
            }
            return null
        })

        tagIds = tagIds.filter(tagId => tagId !== null).join(',')
        setDefaultValue(prevValue => {
            return {
                ...prevValue,
                tagsid: tagIds,
                tagValue: values
            }
        })
    }

    // main image
    const handleMainImage = e => {
        const selectedFile = e.target.files[0]

        // Check if a file is selected
        if (!selectedFile) {
            return
        }

        // Check if the selected file type is an image
        if (!selectedFile.type.startsWith('image/')) {
            toast.error(translate('pleaseSelectImageFile'))
            return
        }
        e.preventDefault()
        const file = e.target.files[0]
        setDefaultValue({ ...defaultValue, imagedefault: file, defaultImageData: URL.createObjectURL(file) })
    }

    // other multiple image
    const handleDrop = acceptedFiles => {
        const imageFiles = acceptedFiles.filter(file => file.type.startsWith('image/'))

        if (acceptedFiles.length !== imageFiles.length) {
            // Some files are not images, show the error toast
            toast.error(translate('onlyImageFilesAllowed'))
            return // Do not proceed with adding non-image files
        }

        setImages([...images, ...acceptedFiles])
    }

    // remove image
    const handleRemoveImage = async (e, id) => {
        e.preventDefault()
        try {
            const res = await deleteImagesApi.deleteImages({ id: id })
            if (res.data.error) {
                toast.error(res.data.message)
            }
            else {
                toast.success(res.data.message)
                const updatedImages = defaultValue.multipleImage.filter(image => image.id !== id)
                setDefaultValue(prevState => ({ ...prevState, multipleImage: updatedImages }))
            }
        } catch (error) {
            toast.error(error)
            console.log(error)
        }
    }

    const handleRemove = (indexToRemove) => {
        setImages(images.filter((_, index) => index !== indexToRemove));
    };

    // swiper other images
    const swiperOption = {
        loop: false,
        speed: 750,
        spaceBetween: 10,
        slidesPerView: 3.5,
        navigation: false,
        autoplay: false,
        breakpoints: {
            0: {
                slidesPerView: 2.5
            },

            768: {
                slidesPerView: 2.5
            },

            992: {
                slidesPerView: 3
            },
            1200: {
                slidesPerView: 3.5
            }
        }
    }

    useEffect(() => {
        dateConfirmation()
    }, [defaultValue.dateValue, defaultValue.publishDateValue]);

    return (
        <div>
            <div className='flex items-center justify-between mb-8'>
                <h1 className="text-[18px] md:text-2xl font-[600] textPrimary">{translate('editNewsLbl')}</h1>
            </div>

            {/* Form Fields */}
            <form className='flex flex-col gap-2.5'>
                {/* Title */}
                <div className="">
                    <label htmlFor="title" className='text-base md:text-lg font-medium textPrimary'>{translate('titleLbl')}</label>
                    <input
                        type="text"
                        className="w-full border borderColor commonRadius dark:text-black px-4 py-2 mt-2 focus:outline-none"
                        placeholder={translate('titleLbl')}
                        defaultValue={defaultValue.defaultTitle}
                        onChange={e => setDefaultValue({ ...defaultValue, defaultTitle: e.target.value })}
                    />
                </div>

                {/* language and slug */}
                <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>

                    {/* Select Language */}
                    <div className="mt-1">

                        <div className='flex flex-col gap-2'>
                            <div className='flex items-center gap-2'>
                                <label htmlFor="language" className='text-base md:text-lg font-medium textPrimary'>{translate('language')}</label>
                            </div>

                            {
                                languagesList?.length > 1 ?
                                    <Select onValueChange={values => languageSelector(values)}>
                                        <SelectTrigger className={`w-full h-[40px] bg-white font-[400] ${defaultValue.languageName ? 'text-black' : ' text-gray-500'}`}>
                                            {
                                                defaultValue?.languageName ?
                                                    <SelectValue placeholder={defaultValue?.languageName} /> :
                                                    <SelectValue placeholder={translate('chooseLanLbl')} />
                                            }

                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectGroup>
                                                {
                                                    languagesList?.map((elem) => {
                                                        return <SelectItem value={JSON.stringify(elem)} key={elem?.id} >{elem?.language}</SelectItem>
                                                    })
                                                }
                                            </SelectGroup>
                                        </SelectContent>
                                    </Select>
                                    :
                                    <div className={`w-full h-[40px] dark:text-black bg-white font-[400] text-black flex items-center border borderColor commonRadius px-4 py-2`}>{settingsData?.data?.default_language?.language}</div>
                            }
                        </div>
                    </div>

                    {/* Slug */}
                    <div className="relative">
                        <div>
                            <div className='flex items-center gap-2'>
                                <label htmlFor="categories" className='text-base md:text-lg font-medium textPrimary'>{translate('slugLbl')}</label>
                                <span> <MetaInfoToolTip info={translate('slugWarningLbl')} /></span>
                            </div>
                        </div>
                        <input
                            type="text"
                            className="w-full border borderColor commonRadius dark:text-black px-4 py-2 mt-2 focus:outline-none"
                            placeholder={translate('slug')}
                            defaultValue={defaultValue.defaultSlug}
                            onChange={e => setDefaultValue({ ...defaultValue, defaultSlug: e.target.value })}
                        />
                    </div>
                </div>

                {/* categories and tags*/}
                <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>

                    {/* categories*/}
                    {
                        showCategory &&
                        <div className="mt-1">

                            <div className='flex flex-col gap-2'>
                                <div className='flex items-center gap-2'>
                                    <label htmlFor="categories" className='text-base md:text-lg font-medium textPrimary'>{translate('catLbl')}</label>
                                </div>

                                <Select onValueChange={(value) => categorySelector(value)} >
                                    <SelectTrigger className={`w-full h-[40px] dark:text-black bg-white font-[400] ${defaultValue.categorydefault ? 'text-black' : ' text-gray-500'}`}>
                                        {
                                            defaultValue?.categorydefault ?
                                                <SelectValue placeholder={defaultValue?.categorydefault} /> :
                                                <SelectValue placeholder={translate('catLbl')} />
                                        }
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectGroup>
                                            {
                                                categories?.map((elem) => {
                                                    return <SelectItem value={JSON.stringify(elem)} key={elem?.id}>{elem.category_name}</SelectItem>
                                                })
                                            }
                                        </SelectGroup>
                                    </SelectContent>
                                </Select>

                            </div>
                        </div>
                    }

                    {/* Tag */}
                    <div className="mt-1">
                        <div className='flex flex-col gap-2'>
                            <div className='flex items-center gap-2'>
                                <label htmlFor="tags" className='text-base md:text-lg font-medium textPrimary'>{translate('tagLbl')}</label>
                            </div>
                            <TagSelect tagsData={tagsData} defaultValue={defaultValue} handleTagChange={handleTagChange} />
                        </div>
                    </div>

                </div>

                {/* sub-categories and post type */}
                <div className={`grid grid-cols-1 ${showSubCategory && subCategories?.length > 0 ? 'md:grid-cols-2' : ''} gap-4`}>

                    {/* sub-categories */}
                    {
                        showSubCategory && subCategories?.length > 0 &&
                        <div className="mt-1">
                            <div className='flex flex-col gap-2'>
                                <div className='flex items-center gap-2'>
                                    <label htmlFor="subcategories" className='text-base md:text-lg font-medium textPrimary'>{translate('subcatLbl')}</label>
                                </div>
                                <Select onValueChange={(value) => subcategorySelector(value)} >
                                    <SelectTrigger className={`w-full h-[40px] dark:text-black bg-white font-[400]${defaultValue.subcategorydefault ? 'text-black' : ' text-gray-500'}`}>
                                        {
                                            defaultValue?.subcategorydefault ?
                                                <SelectValue placeholder={defaultValue?.subcategorydefault} /> :
                                                <SelectValue placeholder={translate('subcatLbl')} />
                                        }
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectGroup>
                                            {
                                                subCategories?.map((elem) => {
                                                    return <SelectItem value={JSON.stringify(elem)} key={elem?.id}>{elem.subcategory_name}</SelectItem>
                                                })
                                            }
                                        </SelectGroup>
                                    </SelectContent>
                                </Select>
                            </div>
                        </div>
                    }

                    {/* Standard Post */}
                    <div className="mt-1">

                        <div className='flex flex-col gap-2'>
                            <div className='flex items-center gap-2'>
                                <label htmlFor="postType" className='text-base md:text-lg font-medium textPrimary'>{translate('postType')}</label>
                            </div>
                            <Select
                                onValueChange={(value) => postSelector(value)}
                                value={defaultValue.standardType ?
                                    JSON.stringify(standardPost.find(item => item.type === defaultValue.standardType)) :
                                    undefined}
                            >
                                <SelectTrigger className={`w-full h-[40px] bg-white font-[400] ${defaultValue.standardType ? 'text-black' : ' text-gray-500'}`}>
                                    <SelectValue placeholder={translate('stdPostLbl')} />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectGroup>
                                        {
                                            standardPost?.map((elem) => {
                                                return <SelectItem value={JSON.stringify(elem)} key={elem?.id}>{elem.type}</SelectItem>
                                            })
                                        }
                                    </SelectGroup>
                                </SelectContent>
                            </Select>
                        </div>
                    </div>
                    {
                        showUrl ?
                            <div className="">
                                <input
                                    type="text"
                                    className="w-full border borderColor commonRadius dark:text-black px-4 py-2 mt-2 focus:outline-none"
                                    placeholder={translate('youtubeUrlLbl')}
                                    value={typeof url === 'object' ? '' : cleanUrlString(url)}
                                    onChange={e => {
                                        const cleanedUrl = cleanUrlString(e.target.value);
                                        setUrl(cleanedUrl);
                                    }}
                                    required
                                />
                            </div> : null
                    }
                    {otherUrl ?
                        <div className="">
                            <input
                                type="text"
                                className="w-full border borderColor commonRadius dark:text-black px-4 py-2 mt-2 focus:outline-none"
                                placeholder={translate('otherUrlLbl')}
                                value={typeof url === 'object' ? '' : cleanUrlString(url)}
                                onChange={e => {
                                    const cleanedUrl = cleanUrlString(e.target.value);
                                    setUrl(cleanedUrl);
                                }}
                                required
                            />
                        </div> : null}
                    {
                        videoUrl ? <>
                            {manageNews?.content_type === 'video_upload' && <>
                                <VideoPlayerModal editNews={true} keyboard={false} url={manageNews?.content_value} type_url={manageNews?.content_type} />
                            </>
                            }
                            <div className="relative bg-white border-2 border-dashed borderColor p-3 flexCenter commonRadius text-center cursor-pointer">
                                <input
                                    type='file'
                                    id='videoInput'
                                    name='video'
                                    accept='video/*'
                                    className="absolute h-full w-full top-0 left-0 bottom-0 right-0 cursor-pointer opacity-0"
                                    onChange={e => handleVideo(e)}
                                />
                                <div className='flexCenter text-gray-400 gap-2  !justify-between w-full'>
                                    {
                                        defaultValue.defaultVideoData?.name ? defaultValue.defaultVideoData?.name : <>
                                            <span className="">{translate('uploadVideoLbl')}</span>
                                            <span> <AiOutlineUpload /></span>
                                        </>
                                    }
                                </div>
                            </div>
                        </>

                            : null
                    }

                </div>

                {/* {location } */}
                <div className='grid grid-cols-1'>
                    {/* Location */}
                    {
                        settingsData?.data?.location_news_mode === '1' &&
                        <div className="mt-1">
                            <div className='flex flex-col gap-2'>
                                <div>
                                    <label htmlFor="location" className='text-base md:text-lg font-medium textPrimary'>{translate('location')}</label>
                                </div>
                                <Select
                                    onValueChange={value => {
                                        // Find the selected location to get its name
                                        const selectedId = JSON.parse(value);
                                        const selectedLocation = locationsData.find(loc => loc.id === selectedId);
                                        setDefaultValue({
                                            ...defaultValue,
                                            defaultLocationId: value,
                                            defaultLocation: selectedLocation?.location_name || ''
                                        });
                                    }}
                                >
                                    <SelectTrigger className={`w-full h-[40px] bg-white font-[400] ${defaultValue.defaultLocation ? 'text-black' : ' text-gray-500'}`}>
                                        {
                                            defaultValue?.defaultLocation ?
                                                <SelectValue placeholder={defaultValue?.defaultLocation} /> :
                                                <SelectValue placeholder={translate('selLocationLbl')} />
                                        }
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectGroup>
                                            {
                                                locationsData?.map((elem) => {
                                                    return <SelectItem key={elem?.id} value={JSON.stringify(elem?.id)}> {elem?.location_name}</SelectItem>
                                                })
                                            }
                                        </SelectGroup>
                                    </SelectContent>
                                </Select>
                            </div>
                        </div>
                    }
                </div>

                {/* Publish Date and Show Till Date */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-2 mt-1">
                    {/* Publish Date  */}
                    <div className='flex flex-col gap-2'>
                        <div className='flex items-center gap-2'>
                            <label htmlFor="publishDate" className='text-base md:text-lg font-medium textPrimary'>{translate('publishDate')}</label>
                        </div>
                        <div className='publish_date datePickerWrapper flex items-center p-2 border borderColor commonRadius bg-white'>
                            <DatePicker
                                dateFormat='yyyy-MM-dd'
                                selected={defaultValue.publishDateValue}
                                placeholderText={translate('publishDate')}
                                clearButtonTitle
                                todayButton={'Today'}
                                minDate={new Date()}
                                onChange={date => setDefaultValue({ ...defaultValue, publishDateValue: date })}
                            />
                            <MdEditCalendar className='form-calender' />
                        </div>
                    </div>

                    {/* Show Till Date */}
                    <div className='flex flex-col gap-2'>
                        <div className='flex items-center gap-2'>
                            <label htmlFor="showTilledDate" className='text-base md:text-lg font-medium textPrimary'>{translate('showTilledDate')}</label>
                        </div>
                        <div className='show_date datePickerWrapper flex items-center p-2 border borderColor commonRadius bg-white'>
                            <DatePicker
                                dateFormat='yyyy-MM-dd'
                                selected={defaultValue.dateValue}
                                placeholderText={translate('showTilledDate')}
                                clearButtonTitle
                                todayButton={'Today'}
                                minDate={addDays(new Date(), 1)}
                                onChange={date => setDefaultValue({ ...defaultValue, dateValue: date })}
                            />
                            <MdEditCalendar className='form-calender' />
                        </div>
                    </div>
                </div>

                {/* Meta Title */}
                <div className="relative">
                    <div className='flex items-center gap-2'>
                        <label htmlFor="metaTitle" className='text-base md:text-lg font-medium textPrimary'>{translate('metaTitleLbl')}</label>
                        <span> <MetaInfoToolTip info={translate('metaTitleWarningLbl')} /></span>
                    </div>
                    <input
                        type="text"
                        className="w-full border borderColor commonRadius dark:text-black px-4 py-2 mt-2 focus:outline-none"
                        placeholder={translate('meta-title')}
                        defaultValue={defaultValue.defaultMetatitle}
                        onChange={e => setDefaultValue({ ...defaultValue, defaultMetatitle: e.target.value })}
                    />
                </div>

                {/* Meta Description and Keywords */}
                <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>

                    {/* Meta Keywords */}
                    <div className="relative">
                        <div className='flex items-center gap-2'>
                            <label htmlFor="metaKeywords" className='text-base md:text-lg font-medium textPrimary'>{translate('meta-keywords')}</label>
                            <span> <MetaInfoToolTip info={translate('metaKeywordWarningLbl')} /></span>
                        </div>
                        <textarea
                            type="text"
                            className="w-full border borderColor commonRadius dark:text-black px-4 py-2 mt-2 focus:outline-none"
                            placeholder={translate('meta-keywords')}
                            defaultValue={defaultValue.defaultMetaKeyword}
                            onChange={e => setDefaultValue({ ...defaultValue, defaultMetaKeyword: e.target.value })}
                        />
                    </div>

                    {/* Meta Description */}
                    <div className="">
                        <div className='flex items-center gap-2'>
                            <label htmlFor="metaDescription" className='text-base md:text-lg font-medium textPrimary'>{translate('metaDescriptionLbl')}</label>
                            <span> <MetaInfoToolTip info={translate('metaDescriptionWarningLbl')} /></span>
                        </div>
                        <textarea
                            className="w-full border borderColor commonRadius dark:text-black px-4 py-2 mt-2 focus:outline-none"
                            placeholder={translate('meta-description')}
                            defaultValue={defaultValue.defaultMetaDescription}
                            onChange={e => setDefaultValue({ ...defaultValue, defaultMetaDescription: e.target.value })}
                        />
                    </div>
                </div>



                {/* Image Upload Section */}
                <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>
                    {/* Image Upload Section */}
                    <div className="mb-2">
                        <div className="relative h-[100px] bg-white border borderColor p-4 flexCenter commonRadius text-center cursor-pointer hover:border-red-500 transition">
                            <input
                                type="file"
                                accept="image/*"
                                className="absolute h-full w-full top-0 left-0 bottom-0 right-0 cursor-pointer opacity-0"
                                onChange={e => handleMainImage(e)}
                            />
                            <div className='flexCenter text-gray-400 gap-2'>
                                <span><AiFillPicture /></span>
                                <span className=""> {translate('uploadMainImageLbl')}</span>
                            </div>
                        </div>
                        {
                            defaultValue.defaultImageData &&
                            <div className='flex items-start justify-start mt-2 w-max relative'>
                                <span onClick={() => setDefaultValue({ ...defaultValue, defaultImageData: null })} className='absolute top-0 right-0 bg-black text-white rounded-full cursor-pointer'><IoIosCloseCircle /> </span>
                                <img src={defaultValue.defaultImageData} alt="Main Upload" className="h-24 w-24 object-cover border commonRadius" />
                            </div>
                        }
                    </div>

                    <div className="">
                        <div className="relative h-[100px] flexCenter bg-white border borderColor p-4 commonRadius text-center cursor-pointer hover:border-red-500 transition">
                            <Dropzone onDrop={handleDrop} multiple={true}>
                                {({ getRootProps, getInputProps }) => (
                                    <div {...getRootProps()} className='dropzone'>
                                        <input {...getInputProps()} className='' accept='image/*' />
                                        <div className='flexCenter text-gray-400 gap-2'>
                                            <span><AiFillPicture /></span>
                                            <span className="">{translate('uploadOtherImageLbl')}</span>
                                        </div>
                                    </div>
                                )}
                            </Dropzone>
                        </div>
                        {
                            <div className='image_slider mt-3'>
                                <Swiper {...swiperOption} key={getDirection()}>

                                    {defaultValue?.multipleImage?.map((file, index) => (
                                        <SwiperSlide key={index}>
                                            <div className='relative border borderColor commonRadius overflow-hidden object-cover h-[100px] w-full'>
                                                <span onClick={e => handleRemoveImage(e, file.id)} className='absolute top-0 right-0 bg-black text-white rounded-full cursor-pointer'><IoIosCloseCircle /> </span>
                                                <img src={file.other_image} alt={`Uploaded ${index}`} />
                                            </div>
                                        </SwiperSlide>
                                    ))}

                                    {images.map((file, index) => (
                                        <SwiperSlide key={index}>
                                            <div className='relative border borderColor commonRadius overflow-hidden object-cover h-[100px] w-full'>
                                                <span onClick={() => handleRemove(index)} className='absolute top-0 right-0 bg-black text-white rounded-full cursor-pointer'><IoIosCloseCircle /> </span>
                                                <img src={URL.createObjectURL(file)} alt={`Uploaded ${index}`} />
                                            </div>
                                        </SwiperSlide>
                                    ))}
                                </Swiper>
                            </div>
                        }
                    </div>
                </div>

                {/* Description Section */}
                <div className='flex flex-col gap-4 mt-4'>
                    <div className='flex items-center justify-between'>
                        <h2 className="text-[18px] font-[600] textPrimary">{translate('description')}</h2>
                    </div>
                    <div className='max-[575px]:max-h-[500px] max-[575px]:overflow-y-auto'>
                        <ReactQuill value={defaultValue?.descriptionValue} onChange={handleChangeContent} />
                    </div>
                    <div className='flex items-center gap-3 justify-center mt-6 md:mt-8'>
                        <button className='commonBtn text-[18px] font-[600] w-[200px]' onClick={e => finalSubmit(e)}>{translate('submitBtn')}</button>
                    </div>
                </div>

            </form>
        </div>
    )
}

export default EditNewsForm


