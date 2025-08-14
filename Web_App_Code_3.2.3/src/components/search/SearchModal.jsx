import React, { useState, useEffect } from 'react'
import {
    Dialog,
    DialogContent,
    DialogTrigger,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog"
import { AiOutlineSearch } from 'react-icons/ai'
import Image from 'next/image'
import { IoClose } from "react-icons/io5";
import { useSelector } from 'react-redux'
import { currentLanguageSelector } from '../store/reducers/languageReducer'
import { useRouter } from 'next/router'
import { settingsSelector } from '../store/reducers/settingsReducer'
import { getNewsApi } from '@/utils/api/api'
import LoadMoreBtn from '../commonComponents/loadermoreBtn/LoadmoreBtn'
import { currentLangCode, formatDate, placeholderImage, translate, truncateText } from '@/utils/helpers'
import Skeleton from 'react-loading-skeleton'
import Link from 'next/link'
import { IoFilter } from "react-icons/io5";
import CategoryTabContent from './CategoryTabContent';
import TagTabContent from './TagTabContent';
import DateTabContent from './DateTabContent';
import { getTagsApi } from '@/utils/api/api';
import toast from 'react-hot-toast';

const SearchModal = ({ onClose = () => { } }) => {

    const currLangCode = currentLangCode();

    const [modalOpen, setModalOpen] = useState(false)

    const settingsData = useSelector(settingsSelector)
    const storedLatitude = settingsData?.lat;
    const storedLongitude = settingsData?.long;

    const currentLanguage = useSelector(currentLanguageSelector)

    const [searchValue, setSearchValue] = useState('')

    const [isLoading, setIsLoading] = useState({
        loading: false,
        loadMoreLoading: false
    })
    const [loadMore, setLoadMore] = useState(false)
    const [data, setData] = useState([])
    const [offset, setOffset] = useState(0)
    const [totalData, setTotalData] = useState('')

    const [currentPage, setCurrentPage] = useState(0)
    const dataPerPage = 4 // number of posts per page


    // filter states 

    const [isFilter, setIsFilter] = useState(false)
    const [activeTab, setActiveTab] = useState(settingsData && settingsData?.data?.category_mode === '1' ? 0 : 1)

    const handleLoadMore = () => {
        setLoadMore(true)
        setOffset(offset + 1)
    }
    const router = useRouter()
    const slug = router?.query?.slug

    const getSearchedNews = async (filterApplied = false) => {

        setApply(filterApplied)
        if (settingsData?.data?.lat || currentPage || searchValue || filterApplied) {
            !loadMore ? setIsLoading({ loading: true }) : setIsLoading({ loadMoreLoading: true })
            try {
                const { data } = await getNewsApi.getNews({
                    offset: offset * dataPerPage,
                    limit: dataPerPage,
                    language_id: currentLanguage?.id,
                    search: searchValue === 'apply' ? '' : searchValue,
                    latitude: storedLatitude,
                    longitude: storedLongitude,
                    category_id: selectedCategoryIds ? selectedCategoryIds : '',
                    tag_id: selectedTagIds ? selectedTagIds : '',
                    last_n_days: lastNDays,
                    date: date?.date,
                    year: date?.year,
                    // merge_tag: 1
                })
                // console.log('resData', data)
                if (data.error) {
                    setIsLoading({ loading: false })
                    setIsLoading({ loadMoreLoading: false })
                    setData([])
                    // clearFilter()
                    return
                }
                setTotalData(data.total)
                setIsLoading({ loading: false })
                setIsLoading({ loadMoreLoading: false })
                if (loadMore) {
                    setData((prevData) => [...prevData, ...data?.data])
                }
                else {
                    setData(data?.data);
                }
                return data
            } catch (error) {
                console.log(error)
                setData([])
                setIsLoading({ loading: false })
            }
        }
    };

    useEffect(() => {
        if (searchValue && currentLanguage?.id && searchValue !== 'apply') {
            const timeout = setTimeout(() => {
                getSearchedNews()
            }, 1500);
            return () => {
                clearTimeout(timeout)
            }
        }
    }, [currentLanguage?.id, settingsData, searchValue])

    useEffect(() => {
        if (searchValue && currentLanguage?.id && searchValue !== 'apply') {
            getSearchedNews()
        }
    }, [currentLanguage?.id, offset])

    useEffect(() => {
        if (searchValue && currentLanguage?.id && searchValue === 'apply') {
            getSearchedNews(true)
        }
    }, [currentLanguage?.id, offset])

    useEffect(() => {
        // console.log('data', data)
    }, [totalData, isLoading, data, searchValue])

    useEffect(() => {
        setLoadMore(false)
        setOffset(0)
        setIsLoading({ loading: true })
        setApply(false)
        setIsFilter(false)

        if (searchValue !== 'apply') {
            setData([])
        }

    }, [searchValue])

    useEffect(() => {
        if (!modalOpen) {
            setSearchValue('')
            setIsFilter(false)
            setApply(false)
            setData([])
            clearFilter()
        }

        if (modalOpen) {
            onClose()
        }

    }, [modalOpen])

    // Handle closing the dialog when clicking outside
    const handleOpenChange = (open) => {
        setModalOpen(open);
        setIsFilter(false)
    };

    const filterTabs = [
        {
            id: 0,
            tab: translate('catLbl')
        },
        {
            id: 1,
            tab: translate('tagLbl')
        },
        {
            id: 2,
            tab: translate('date')
        },
    ];

    const [selectedCategoryIds, setSelectedCategoryIds] = useState("");
    const [selectedTagIds, setSelectedTagIds] = useState("");
    const [selectedCategories, setSelectedCategories] = useState({});
    const [selectedTags, setSelectedTags] = useState({});

    const [apply, setApply] = useState(false)

    // Tag related states
    const [isLoadingTags, setIsLoadingTags] = useState({
        loading: false,
        loadMoreLoading: false
    });
    const [loadMoreTags, setLoadMoreTags] = useState(false);
    const [tagsData, setTagsData] = useState([]);
    const [tagsOffset, setTagsOffset] = useState(0);
    const [totalTags, setTotalTags] = useState('');

    const limit = 20;

    const handleLoadMoreTags = () => {
        setLoadMoreTags(true);
        setTagsOffset(tagsOffset + 1);
    };

    const getTags = async () => {
        if (!currentLanguage?.id) return;

        !loadMoreTags ? setIsLoadingTags({ loading: true }) : setIsLoadingTags({ loadMoreLoading: true });
        try {
            const { data } = await getTagsApi.getTags({
                offset: tagsOffset * limit,
                limit: limit,
                language_id: currentLanguage?.id
            });

            if (!data?.error) {
                setTotalTags(data?.total);
                if (loadMoreTags) {
                    setTagsData((prevData) => [...prevData, ...data?.data]);
                } else {
                    setTagsData(data?.data);
                }
                setIsLoadingTags({ loading: false });
                setIsLoadingTags({ loadMoreLoading: false });
            } else {
                setTagsData([]);
                console.log('tagsSect error =>', data?.message);
            }
        } catch (error) {
            console.log(error);
            setTagsData([]);
        } finally {
            setIsLoadingTags({ loading: false });
        }
    };

    // Load tags when component mounts or when language/offset changes
    useEffect(() => {

        if (currentLanguage?.id) {
            getTags();
            sessionStorage.setItem('tagCurentLangId', currentLanguage?.id)

            const prevLanguageId = sessionStorage.getItem('tagCurentLangId')
            if
                (Number(prevLanguageId) !== currentLanguage.id) {
                setTagsOffset(0)
            }

        }
    }, [currentLanguage?.id, tagsOffset]);

    const [date, setDate] = useState({
        date: '',
        year: ''
    })

    const currentDate = new Date()

    const [displayDate, setDisplayDate] = useState(new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate()));
    const [selectedDate, setSelectedDate] = useState(new Date());
    const [activeDateTab, setActiveDateTab] = useState('custom');

    const [lastNDays, setLastNDays] = useState(null)

    useEffect(() => {
        // console.log('selectedCategoryIds useEffect', selectedCategoryIds);
        // console.log('selectedTagIds useEffect', selectedTagIds);
        // console.log('lastNDays', lastNDays);
        // console.log('date', date.date);
        // console.log('year', date.year);
    }, [selectedCategoryIds, selectedTagIds, date, lastNDays])

    useEffect(() => {
        if (isFilter) {
            setData([])
            setIsLoading({ loadMoreLoading: false })
            setLoadMore(false)
            setOffset(0)
        }
    }, [isFilter])

    const clearFilter = () => {
        setSelectedCategoryIds('')
        setSelectedTagIds('')
        setSelectedCategories({})
        setSelectedTags({})
        setDate({
            date: '',
            year: ''
        })
        setLastNDays(null)
        setSelectedDate(new Date())
        setActiveDateTab('custom')
        // setOffset(0)
    }

    useEffect(() => {
        // if (data && data) {
        //     if (totalData === data?.length && searchValue === 'apply') {
        //         clearFilter()
        //     }
        // }
    }, [totalData, data])

    const applyFilter = (type) => {
        if (type === 'clear') {
            clearFilter()
        }
        if (type === 'apply') {

            if (selectedCategoryIds || selectedTagIds || lastNDays || date.date || date.year) {
                setSearchValue('apply')
                // console.log('selectedCategoryIds', selectedCategoryIds);
                // console.log('selectedTagIds', selectedTagIds);
                // console.log('lastNDays', lastNDays);
                // console.log('date', date.date);
                // console.log('year', date.year);
                getSearchedNews(true)
                setIsFilter(false)
            }
            else {
                toast.error(translate('pleaseApplyFilter'))
            }
        }
    }



    return (
        <div className=''>
            <Dialog open={modalOpen} onOpenChange={handleOpenChange}>
                <DialogTrigger asChild onClick={() => setModalOpen(true)}>
                    <button aria-label="Search" className='commonBg dark:bg-white py-2 px-3 commonRadius transition-all duration-500 !primaryColor hover:!text-white hover:!hoverBg'><AiOutlineSearch size={23} /></button>
                </DialogTrigger>
                <DialogContent className="max-w-[90%] md:max-w-[70%] lg:max-w-[50%] max-h-fit bg-white commonRadius p-0 border-none searchModalWrapper overflow-hidden">
                    <div className='flex flex-col p-3 md:p-6 gap-6'>
                        <DialogHeader className={'border-b pb-3'}>
                            <div className='flex items-center justify-between'>
                                <DialogTitle className='text-[#1B2D51]'>{translate('searchNews')}</DialogTitle>

                                <button className='bg-transparent border borderColor w-[44px] h-[40px] flexCenter commonRadius primaryColor focus:outline-none' onClick={() => setModalOpen(false)}><IoClose size={24} /></button>

                            </div>
                        </DialogHeader>

                        <div className='flex items-center gap-3'>
                            <div className='flex items-center justify-between w-full p-2 sm:p-3 border borderColor rounded-[8px]'>
                                <input type="text" placeholder={translate('search')} className='max-[360px]:w-[150px] w-full text-black focus:outline-none text-[18px]' onChange={(e) => setSearchValue(e.target.value)} />
                            </div>
                            <div className="text-[#1B2D51] font-semibold md:text-lg">
                                <button className='border borderColor rounded-[8px] p-2 sm:p-3 flexCenter gap-2 w-full h-[40px] sm:h-auto' onClick={() => setIsFilter(true)}>
                                    <span className='hidden sm:block'>{translate('filter')}</span>
                                    <IoFilter />
                                </button>
                            </div>
                        </div>
                        {
                            !isFilter && searchValue !== '' &&
                            <div className='flex flex-col gap-6 max-h-[450px] pr-2 overflow-hidden searchContentWrapper overflow-y-scroll'>

                                {
                                    isLoading.loading ? [...Array(3)].map((_, index) => (
                                        <div key={index} className='flex items-center gap-3'>
                                            <div className='w-[70px] h-[70px] md:w-[80px] md:h-[80px] lg:w-[100px] lg:h-[100px] object-cover commonRadius'>
                                                <Skeleton className='h-full w-full' />
                                            </div>
                                            <div className='w-full'>
                                                <Skeleton height={40} className='w-full' />
                                            </div>
                                        </div>
                                    )) :
                                        data && data.length > 0 ?
                                            data?.map((element) => {
                                                return <Link key={element?.id}
                                                    href={{ pathname: `/${currLangCode}/news/${element?.slug}`, query: { language_id: element?.language_id } }}
                                                    title='detail-page'
                                                    onClick={() => setModalOpen(false)}
                                                >
                                                    <div className='flex items-center gap-3 text-[#1B2D51] font-[600] text-lg'>
                                                        <Image src={element?.image} onError={placeholderImage} alt={element?.title} loading='lazy' width={0} height={0} className='hidden lg:block w-[102px] h-[110px] object-cover rounded-2xl' />
                                                        <div className='border borderColor p-2 md:p-3 lg:p-4 xl:p-5 rounded-2xl flex flex-col gap-2 w-full'>
                                                            <div className='flex items-center justify-between border-b pb-2'>
                                                                <div className='flex items-center gap-3 font-normal text-sm sm:text-base'>
                                                                    {
                                                                        element?.tag_name &&
                                                                        <div>
                                                                            <span className='textSecondary'>{translate('tagLbl')}: </span>
                                                                            <span className='text-[#1B2D51]'>{element?.tag_name}</span>
                                                                        </div>
                                                                    }
                                                                    {
                                                                        element?.category?.category_name &&
                                                                        <div>
                                                                            <span className='textSecondary'>{translate('catLbl')}: </span>
                                                                            <span className='text-[#1B2D51]'>{element?.category?.category_name}</span>
                                                                        </div>
                                                                    }
                                                                </div>
                                                                <div className='date text-sm sm:text-base'>
                                                                    <span className='textSecondary font-normal'>
                                                                        {new Date(element?.published_date).toLocaleString('en-us', {
                                                                            day: 'numeric',
                                                                            month: 'short',
                                                                            year: 'numeric'
                                                                        })}
                                                                    </span>
                                                                </div>
                                                            </div>
                                                            <div>
                                                                <h1 className='line-clamp-2 text-sm sm:text-base md:text-lg font-medium text-black'>{truncateText(element.title, 150)}</h1>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </Link>

                                            })
                                            :
                                            !isLoading.loading && searchValue !== '' &&
                                            <div className='text-[#1B2D51] flexCenter h-[450px] overflow-hidden font-[600] text-lg'>
                                                {translate('nodatafound')}
                                            </div>
                                }
                                {data && data.length > 1 && !isLoading.loading && searchValue && totalData > dataPerPage && totalData !== data.length ? (
                                    <div className='flexCenter'>
                                        <LoadMoreBtn handleLoadMore={handleLoadMore} loadMoreLoading={isLoading.loadMoreLoading} />
                                    </div>
                                ) : null}
                            </div>
                        }

                        {
                            isFilter &&
                            <div className='flex flex-col gap-6 max-h-[600px] lg:max-h-[700px] overflow-auto'>
                                <div>
                                    <div className='bg-[#1B2D511A] commonRadius p-2 max-[1199px]:w-max w-[550px] h-[50px] flex items-center justify-between max-[1199px]:justify-center gap-3'>
                                        {
                                            filterTabs?.map((ele, index) => {
                                                return <span className={`cursor-pointer h-[35px] w-max px-2 lg:w-[154px] font-medium rounded flexCenter ${activeTab === index ? 'bg-[#1B2D51] text-white' : 'text-[#1B2D51]'} ${index === 0 && settingsData && settingsData?.data?.category_mode !== '1' ? '!hidden' : ''}`}
                                                    onClick={() => setActiveTab(index)}
                                                >
                                                    {
                                                        ele.tab
                                                    }
                                                </span>
                                            })
                                        }
                                    </div>
                                </div>

                                <div>
                                    {
                                        activeTab === 0 && settingsData && settingsData?.data?.category_mode === '1' &&
                                        <CategoryTabContent
                                            selectedCategoryIds={selectedCategoryIds}
                                            setSelectedCategoryIds={setSelectedCategoryIds}
                                            selectedCategories={selectedCategories}
                                            setSelectedCategories={setSelectedCategories}
                                            offset={offset}
                                        />
                                    }
                                    {
                                        activeTab === 1 &&
                                        <TagTabContent
                                            selectedTagIds={selectedTagIds}
                                            setSelectedTagIds={setSelectedTagIds}
                                            selectedTags={selectedTags}
                                            setSelectedTags={setSelectedTags}
                                            tagsData={tagsData}
                                            isLoadingTags={isLoadingTags}
                                            totalTags={totalTags}
                                            handleLoadMoreTags={handleLoadMoreTags}
                                            offset={offset}
                                        />
                                    }
                                    {
                                        activeTab === 2 &&
                                        <DateTabContent
                                            setDate={setDate}
                                            setLastNDays={setLastNDays}
                                            displayDate={displayDate}
                                            setDisplayDate={setDisplayDate}
                                            selectedDate={selectedDate}
                                            setSelectedDate={setSelectedDate}
                                            activeDateTab={activeDateTab}
                                            setActiveDateTab={setActiveDateTab}
                                            offset={offset}
                                        />
                                    }
                                </div>

                                <div className='flexCenter !justify-end gap-3'>
                                    <button className='!font-medium !h-[40px] max-[360px]:w-max w-[145px] p-[6px_12px] bg-transparent text-[#1B2D51] dark:text-black border borderColor rounded-[8px]' onClick={() => applyFilter('clear')}>{translate('clear')}</button>
                                    <button className='!font-medium !h-[40px] max-[360px]:w-max w-[145px] commonBtn !rounded-[8px]' onClick={() => applyFilter('apply')}>{translate('apply')}</button>
                                </div>

                            </div>
                        }

                    </div>
                </DialogContent>
            </Dialog>
        </div>
    )
}

export default SearchModal