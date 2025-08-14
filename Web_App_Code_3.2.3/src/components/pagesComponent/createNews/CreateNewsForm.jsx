import React, { useState, useEffect } from 'react'
import DatePicker from 'react-datepicker'
import { SlCalender } from 'react-icons/sl'
import { getDirection, translate } from '@/utils/helpers';
import { getCategoriesApi, getLocationApi, getSubCategoryByCategoryIdApi, getTagsApi } from '@/utils/api/api';
import { languagesListSelector } from '@/components/store/reducers/languageReducer';
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

// Import Swiper styles
import 'swiper/css';
import 'swiper/css/free-mode';
import 'swiper/css/pagination';
import MetaInfoToolTip from './MetaInfoToolTip';
import AiCreateNewsApi from '@/gemini-api/AiCreateNewsApi'
import { BsMagic, BsRobot } from 'react-icons/bs';
import ReactQuill from 'react-quill'

const CreateNewsForm = ({ defaultValue, setDefaultValue, images, setImages, createNewsLanguage, content, handleChangeContent, finalSubmit, aiPrompt, setAiPrompt, isGeneratingContent, generateAIContent, setVideoSet }) => {

    const settingsData = useSelector(settingsSelector)
    const languagesList = useSelector(languagesListSelector)


    const [categories, setCategories] = useState([])
    const [subCategories, setSubCategories] = useState([])
    const [locationsData, setLocationsData] = useState([])
    const [tagsData, setTagsData] = useState([])

    const [showCategory, setShowCategory] = useState(defaultValue.defaultLanguage ? true : false)
    const [showSubCategory, setShowSubCategory] = useState(defaultValue.defaultSubCategory ? true : false)
    const [showUrl, setShowURl] = useState(false)
    const [otherUrl, setOtherUrl] = useState(false)
    const [videoUrl, setVideoUrl] = useState(false)

    const [isGeneratingMeta, setIsGeneratingMeta] = useState(false)


    // category api call
    const getCategories = async () => {
        try {
            const { data } = await getCategoriesApi.getCategories({
                offset: '',
                limit: '70',
                language_id: createNewsLanguage.id
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
                    language_id: createNewsLanguage.id
                })
                if (res.data?.data?.length === 0) {
                    setSubCategories([]);
                    if (!defaultValue.defaultSubCategory) {
                        setShowSubCategory(false)
                    }
                    return
                }
                setSubCategories(res.data?.data)
                setShowSubCategory(true)
            } catch (error) {
                if (error === 'No Data Found') {
                    if (!defaultValue.defaultSubCategory) {
                        setShowSubCategory(false)
                    }
                    setSubCategories([])
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
            const { data } = await getTagsApi.getTags({ language_id: createNewsLanguage.id })
            setTagsData(data?.data)
        } catch (error) {
            console.log(error)
        }
    }


    // load language data to reducer
    const languageSelector = async value => {
        if (!value) {
            console.error('Empty value received in languageSelector');
            return;
        }

        try {
            setShowCategory(true)
            const selectedData = JSON.parse(value)
            setDefaultValue(prevState => ({ ...prevState, defaultLanguage: selectedData.language }));
            setCreateNewsCurrentLanguage(selectedData.language, selectedData.code, selectedData.id)
            setDefaultValue(prevState => ({ ...prevState, defaultCategoryID: null, defaultCategory: null }));
            setShowSubCategory(false)
        } catch (error) {
            console.error('Error parsing language selection:', error, 'Value:', value);
        }
    }


    // change category
    const categorySelector = (value) => {
        if (!value) {
            console.error('Empty value received in categorySelector');
            return;
        }

        try {
            const selectedCategory = JSON.parse(value);
            if (!selectedCategory || typeof selectedCategory !== 'object') {
                console.error('Invalid selection value:', value);
                return;
            }
            setDefaultValue({ ...defaultValue, defaultCategoryID: selectedCategory?.id, defaultCategory: selectedCategory?.category_name })
            setSubCategories([]);
            getSubCategories(selectedCategory?.id)
        } catch (error) {
            console.error('Error parsing category selection:', error, 'Value:', value);
        }
    }

    // change sub-category
    const subcategorySelector = (value) => {
        if (!value) {
            console.error('Empty value received in subcategorySelector');
            return;
        }

        try {
            const selectedSubCategory = JSON.parse(value);
            setDefaultValue({ ...defaultValue, defaultSubCategoryID: selectedSubCategory?.id, defaultSubCategory: selectedSubCategory?.subcategory_name })
        } catch (error) {
            console.error('Error parsing subcategory selection:', error, 'Value:', value);
        }
    }

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
        setVideoSet(true)
        // setVideoData(e.target.files[0]);
    }

    // select post type
    const postSelector = value => {
        if (!value) {
            console.error('Empty value received in postSelector');
            return;
        }

        try {
            const selectedType = JSON.parse(value);
            if (!selectedType || typeof selectedType !== 'object') {
                console.error('Invalid selection value:', value);
                return;
            }
            // Find the selected option in the standardPost array
            const contentType = standardPost.find(elem => elem.id === selectedType?.id)

            // Clear video data if switching away from video_upload
            if (defaultValue.defaultType === 'video_upload' && contentType.name !== 'video_upload') {
                setDefaultValue({
                    ...defaultValue,
                    defaultVideoData: null,
                    defaultSelector: contentType.type,
                    defaultType: contentType.name,
                    defaultUrl: null
                });
                setVideoSet(false);
            } else if (contentType.name == 'standard_post') {
                setDefaultValue({
                    ...defaultValue,
                    defaultSelector: translate('stdPostLbl'),
                    defaultType: 'standard_post',
                    defaultUrl: null
                })
                setShowURl(false)
                setVideoUrl(false)
                setOtherUrl(false)
            } else if (contentType.name == 'video_youtube') {
                setDefaultValue({ ...defaultValue, defaultSelector: translate('videoYoutubeLbl'), defaultType: 'video_youtube' })
                setShowURl(true)
                setOtherUrl(false)
                setVideoUrl(false)
            } else if (contentType.name == 'video_other') {
                setDefaultValue({ ...defaultValue, defaultSelector: translate('videoOtherUrlLbl'), defaultType: 'video_other' })
                setShowURl(false)
                setOtherUrl(true)
                setVideoUrl(false)
            } else if (contentType.name == 'video_upload') {
                setDefaultValue({ ...defaultValue, defaultSelector: translate('videoUploadLbl'), defaultType: 'video_upload' })
                setShowURl(false)
                setVideoUrl(true)
                setOtherUrl(false)
            } else {
                setShowURl(false)
                setVideoUrl(false)
                setOtherUrl(false)
            }
        } catch (error) {
            console.error('Error parsing post type selection:', error, 'Value:', value);
        }
    }

    const dateConfirmation = () => {

        const showTillDate = defaultValue.defaultStartDate;
        const publishDate = defaultValue.defaultPublishDate;

        if (publishDate && showTillDate && publishDate > showTillDate) {
            toast.error(translate('dateConfirmation'));
            return; // Prevent form submission
        }
    }

    useEffect(() => {
        getLocation()
    }, [])

    useEffect(() => {
        if (createNewsLanguage?.id) {
            getCategories()
            getTags()
            setShowCategory(true)
        }
    }, [createNewsLanguage.id])

    useEffect(() => {
        if (defaultValue.defaultCategoryID && defaultValue.defaultSubCategory) {
            getSubCategories(defaultValue.defaultCategoryID)
            setShowSubCategory(true)
        }
    }, [])

    // Inside the StepOne component, add a useEffect to log values for debugging
    useEffect(() => {

    }, [defaultValue, categories, subCategories]);

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
                defaultTag: tagIds,
                defaultTagName: values.join(',')
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
        setDefaultValue({ ...defaultValue, defaultImageData: URL.createObjectURL(file), defaultImagefile: file })
    }

    // other multiple image
    const handleDrop = acceptedFiles => {
        const imageFiles = acceptedFiles.filter(file => file.type.startsWith('image/'))

        if (acceptedFiles.length !== imageFiles.length) {
            // Some files are not images, show the error toast
            toast.error(translate('onlyImageFilesAllowed'))
            return // Do not proceed with adding non-image files
        }

        // All files are images, add them to the state
        setImages([...images, ...imageFiles])
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
    }, [defaultValue.defaultStartDate, defaultValue.defaultPublishDate])

    // Add this useEffect to restore UI state based on defaultValue.defaultType
    useEffect(() => {
        if (defaultValue.defaultType) {
            if (defaultValue.defaultType === 'video_youtube') {
                setShowURl(true)
                setOtherUrl(false)
                setVideoUrl(false)
            } else if (defaultValue.defaultType === 'video_other') {
                setShowURl(false)
                setOtherUrl(true)
                setVideoUrl(false)
            } else if (defaultValue.defaultType === 'video_upload') {
                setShowURl(false)
                setOtherUrl(false)
                setVideoUrl(true)
                if (defaultValue.defaultVideoData) {
                    setVideoSet(true)
                }
            } else {
                // standard_post
                setShowURl(false)
                setOtherUrl(false)
                setVideoUrl(false)
            }
        }
    }, [defaultValue.defaultType]);

    // AI meta information generation
    const generateMetaInfo = async (e) => {
        e.preventDefault()

        // console.log('defaultValue.defaultLanguage', defaultValue.defaultLanguage)
        if (!defaultValue.defaultTitle) {
            toast.error(translate('addTitleToAutoGenerateMetaInfo'))
            return
        }
        if (!defaultValue.defaultLanguage) {
            toast.error(translate('selectlanguage'))
            return
        }

        setIsGeneratingMeta(true)
        try {
            const data = await AiCreateNewsApi.generateMetaInfo({
                title: defaultValue.defaultTitle,
                language: createNewsLanguage.name,
                languageCode: createNewsLanguage.code
            })

            if (data) {
                // Ensure we have default values if any fields are missing
                const updatedValues = {
                    ...defaultValue,
                    defaultMetatitle: data.meta_title || '',
                    defaultMetaDescription: data.meta_description || '',
                    defaultMetaKeyword: data.meta_keywords || '',
                    defaultSlug: data.slug || ''
                }

                setDefaultValue(updatedValues)
                toast.success(translate('metaInformationApplied'))
            } else {
                console.error('No data returned from generateMetaInfo')
                toast.error(translate('failedToGenerateMetaInfo'))
            }
        } catch (error) {
            console.error('Error generating meta information:', error)
            toast.error(`${translate('failedToGenerateMetaInfo')}: ${error.message || 'Unknown error'}`)
        } finally {
            setIsGeneratingMeta(false)
        }
    }

    useEffect(() => {
        if (languagesList?.length < 2) {
            setShowCategory(true)
            setDefaultValue(prevState => ({ ...prevState, defaultLanguage: settingsData?.data?.default_language?.language }));
            setCreateNewsCurrentLanguage(settingsData?.data?.default_language?.languag, settingsData?.data?.default_language?.code, settingsData?.data?.default_language?.id)
            setDefaultValue(prevState => ({ ...prevState, defaultCategoryID: null, defaultCategory: null }));
            setShowSubCategory(false)
        }

    }, [languagesList])

    useEffect(() => {
        // console.log(createNewsLanguage,'createNewsLanguage in useEffect')
    }, [createNewsLanguage])

    return (
        <div>

            <div className='flex items-center justify-between mb-8'>
                <h1 className="text-[18px] md:text-2xl font-[600] textPrimary">{translate('createNewsLbl')}</h1>
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
                    <div className='flex items-center justify-between flex-wrap max-[450px]:mt-2'>
                        <span className='text-sm textPrimary font-medium'>
                            {translate('addTitleToAutoGenerateMetaInfo')}
                        </span>
                        <button
                            className={` ${isGeneratingMeta || !defaultValue.defaultTitle ? 'p-[6px_12px] bg-gray-500 rounded-[6px] text-gray-300 !cursor-not-allowed' : 'commonBtn'}  mt-2 flexCenter text-sm`}
                            onClick={(e) => generateMetaInfo(e)}
                            disabled={isGeneratingMeta || !defaultValue.defaultTitle}
                        >
                            {isGeneratingMeta ? `${translate('generating')}` : <><BsMagic className="me-1" /> {translate('autoGenerateMetaInfo')}</>}
                        </button>
                    </div>
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
                                    <Select
                                        onValueChange={values => languageSelector(values)}
                                        defaultValue={defaultValue.defaultLanguage ?
                                            JSON.stringify(languagesList.find(lang => lang.language === defaultValue.defaultLanguage)) :
                                            undefined}
                                    >
                                        <SelectTrigger className={`w-full h-[40px] bg-white font-[400] ${defaultValue.defaultLanguage ? 'text-black' : ' text-gray-500'}`}>
                                            <SelectValue placeholder={translate('chooseLanLbl')} />
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
                                <Select
                                    onValueChange={(value) => categorySelector(value)}
                                    value={defaultValue.defaultCategory ?
                                        (() => {
                                            const foundCategory = categories.find(cat =>
                                                cat.category_name === defaultValue.defaultCategory
                                            );
                                            return foundCategory ? JSON.stringify(foundCategory) : undefined;
                                        })() :
                                        undefined
                                    }
                                >
                                    <SelectTrigger className={`w-full h-[40px] bg-white font-[400] ${defaultValue.defaultCategory ? 'text-black' : ' text-gray-500'}`}>
                                        <SelectValue placeholder={translate('catLbl')} />
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
                                <Select
                                    onValueChange={(value) => subcategorySelector(value)}
                                    value={defaultValue.defaultSubCategory ?
                                        (() => {
                                            const foundSubCategory = subCategories.find(subcat =>
                                                subcat.subcategory_name === defaultValue.defaultSubCategory
                                            );
                                            return foundSubCategory ? JSON.stringify(foundSubCategory) : undefined;
                                        })() :
                                        undefined
                                    }
                                >
                                    <SelectTrigger className={`w-full h-[40px] dark:text-black bg-white font-[400]${defaultValue.defaultSubCategory ? 'text-black' : ' text-gray-500'}`}>
                                        <SelectValue placeholder={translate('subcatLbl')} />
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
                                onValueChange={(value, option) => postSelector(value, option)}
                                defaultValue={defaultValue.defaultSelector ?
                                    JSON.stringify(standardPost.find(post => post.type === defaultValue.defaultSelector)) :
                                    undefined}
                            >
                                <SelectTrigger className={`w-full h-[40px] bg-white font-[400] ${defaultValue.defaultSelector ? 'text-black' : ' text-gray-500'}`}>
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
                                    defaultValue={defaultValue.defaultUrl}
                                    onChange={e => setDefaultValue({ ...defaultValue, defaultUrl: e.target.value })}
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
                                defaultValue={defaultValue.defaultUrl}
                                onChange={e => setDefaultValue({ ...defaultValue, defaultUrl: e.target.value })}
                                required
                            />
                        </div> : null}
                    {
                        videoUrl ? <>
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
                                    onValueChange={value => setDefaultValue({ ...defaultValue, defaultLocation: value })}
                                    defaultValue={defaultValue.defaultLocation || undefined}
                                >
                                    <SelectTrigger className={`w-full h-[40px] bg-white font-[400] ${defaultValue.defaultLocation ? 'text-black' : ' text-gray-500'}`}>
                                        <SelectValue placeholder={translate('selLocationLbl')} />
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

                                selected={defaultValue.defaultPublishDate}
                                placeholderText={translate('publishDate')}
                                clearButtonTitle
                                todayButton={'Today'}
                                minDate={new Date()}
                                onChange={date => setDefaultValue({ ...defaultValue, defaultPublishDate: date })}
                            />
                            <SlCalender className='form-calender' />
                        </div>
                    </div>

                    {/* Show Till Date */}
                    <div className='flex flex-col gap-2'>
                        <div className='flex items-center gap-2'>
                            <label htmlFor="showTilledDate" className='text-base md:text-lg font-medium textPrimary'>{translate('showTilledDate')}</label>
                        </div>
                        <div className='show_date datePickerWrapper flex items-center p-2 border borderColor commonRadius bg-white dark:!text-black'>
                            <DatePicker
                                dateFormat='yyyy-MM-dd'
                                selected={defaultValue.defaultStartDate}
                                placeholderText={translate('showTilledDate')}
                                clearButtonTitle
                                todayButton={'Today'}
                                minDate={addDays(new Date(), 1)}
                                onChange={date => setDefaultValue({ ...defaultValue, defaultStartDate: date })}
                            />
                            <SlCalender className='form-calender' />
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
                            id='metaKeywords'
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
                            id='metaDescription'
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
                            images && images?.length > 0 &&
                            <div className='image_slider mt-3'>
                                <Swiper {...swiperOption} key={getDirection()}>
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
                <div className='flex flex-col gap-4'>
                    <div className='flex items-center justify-between'>
                        <h2 className="text-[18px] font-[600] textPrimary">{translate('description')}</h2>
                    </div>

                    <div className='ai-assistant mb-3'>
                        <div className='flex items-center gap-4 mb-2'>
                            <input
                                type='text'
                                className='w-[90%] border borderColor commonRadius dark:text-black px-4 py-2 focus:outline-none'
                                placeholder={translate('enterPrompt')}
                                value={aiPrompt}
                                onChange={(e) => setAiPrompt(e.target.value)}
                            />
                            <button
                                onClick={generateAIContent}
                                disabled={isGeneratingContent || !aiPrompt}
                                className='commonBtn flexCenter text-sm'
                            >
                                {isGeneratingContent ? `${translate('generating')}` : <><BsRobot className="me-1" /> {translate('generate')}</>}
                            </button>
                        </div>
                        <span className="text-muted text-sm textPrimary font-medium">{translate('tryPrompt')}</span>
                    </div>

                    <div className='max-[575px]:max-h-[500px] max-[575px]:overflow-y-auto'>
                        <ReactQuill value={content} onChange={handleChangeContent} />
                    </div>
                    <div className='flex items-center gap-3 justify-center mt-6 md:mt-8'>
                        <button className='commonBtn text-[18px] font-[600] w-[200px]' onClick={e => finalSubmit(e)}>{translate('submitBtn')}</button>
                    </div>
                </div>
            </form>
        </div>
    )
}

export default CreateNewsForm