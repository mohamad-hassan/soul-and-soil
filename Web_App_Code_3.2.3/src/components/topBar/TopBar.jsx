'use client'
import React, { useState, useEffect } from 'react'
import { SlCalender } from 'react-icons/sl'
import { HiArrowLongUp, HiArrowLongDown } from 'react-icons/hi2'
import { TiWeatherPartlySunny } from "react-icons/ti"
import ThemeToggler from './ThemeToggler'
import { registertokenApi } from '@/utils/api/api'
import { currentLanguageSelector } from '../store/reducers/languageReducer'
import { useDispatch, useSelector } from 'react-redux'
import { loadLocation, settingsSelector } from '../store/reducers/settingsReducer'
import { currentLangCode, defaultLanguageCode, isLogin, translate } from '@/utils/helpers'
import { checkLocationPermissionGranted, checkPermissionsSelector, isLocationPermissionCheck, isNotificationPermissionCheck } from '../store/reducers/CheckPermissionsReducer'
import axios from 'axios'
import toast from 'react-hot-toast'
import { useRouter } from 'next/router'
import dynamic from 'next/dynamic'

// Predefine dimensions to prevent layout shifts
const WEATHER_CONTAINER_HEIGHT = '50px'
const SOCIAL_MEDIA_HEIGHT = '32px'

// Dynamic imports with explicit loading state management
const SocialMedias = dynamic(() => import('./SocialMedias'), {
  ssr: false,
  loading: () => (
    <div style={{ height: SOCIAL_MEDIA_HEIGHT, width: '150px' }} className="animate-pulse bg-gray-300 rounded" />
  )
})

const LanguageDropdown = dynamic(() => import('../dropdowns/LanguageDropdown'), {
  ssr: false,
  loading: () => (
    <div style={{ height: '36px', width: '120px' }} className="animate-pulse bg-gray-300 rounded" />
  )
})

const TopBar = ({ setMorePagesOffset, setIsLoadMorePages }) => {

  const [weather, setWeather] = useState(null)

  const router = useRouter()
  const dispatch = useDispatch()

  const settingsData = useSelector(settingsSelector)
  const checkPermissions = useSelector(checkPermissionsSelector)
  const checkNotificationPermissionOnce = checkPermissions?.data?.isNotificaitonPermissionCheck
  const checkLocationPermissonOnce = checkPermissions?.data?.isLocaitonPermissionCheck

  const locationWiseNews = settingsData?.data?.location_news_mode
  const weatherMode = settingsData?.data?.weather_mode

  const currentLanguage = useSelector(currentLanguageSelector)

  const currLangCode = currentLangCode()
  const defaultLangCode = defaultLanguageCode()

  const weatherApi = async () => {
    return new Promise((resolve, reject) => {
      try {
        if ('geolocation' in navigator) {
          navigator.geolocation.getCurrentPosition(async position => {
            const { latitude, longitude } = position.coords

            if (locationWiseNews === '1') {
              loadLocation(latitude, longitude)
            } else {
              loadLocation(null, null)
            }

            try {
              const response = await axios.get(
                `https://api.weatherapi.com/v1/forecast.json?key=${process.env.NEXT_PUBLIC_WEATHER_API_KEY}&q=${latitude},${longitude}&days=1&aqi=no&alerts=no&lang=${currentLanguage?.code}`
              )
              setWeather(response?.data)
              checkLocationPermissionGranted({ data: { isLocationPermission: 'granted' } })
              resolve(response.data)
            } catch (error) {
              console.error('Weather API error:', error)
              reject(error)
            }
          })
        } else {
          toast.error('Geolocation not supported')
          checkLocationPermissionGranted({ data: { isLocationPermission: 'not supported' } })
        }
      } catch (error) {
        loadLocation(null, null)
        reject(error)
      }
    })
  }

  useEffect(() => {
    if (weatherMode === '1') {
      weatherApi()
    }
  }, [currentLanguage, locationWiseNews, weatherMode])

  // Get today's date
  const today = new Date()
  const dayOfMonth = today.getDate()
  const year = today.getFullYear()
  const month = today.toLocaleString('default', { month: 'long' })

  const maxTempC = weather?.forecast?.forecastday?.[0]?.day?.maxtemp_c
  const minTempC = weather?.forecast?.forecastday?.[0]?.day?.mintemp_c

  const storedLatitude = settingsData?.lat
  const storedLongitude = settingsData?.long

  const registerToken = async (fcmId) => {
    if (fcmId) {
      try {
        await registertokenApi.registertoken({
          language_id: currentLanguage?.id,
          token: fcmId,
          latitude: storedLatitude,
          longitude: storedLongitude
        })
      } catch (error) {
        console.error('registerFcmTokenApi Error:', error)
      }
    }
  }

  useEffect(() => {
    if (checkPermissions?.data?.isNotificaitonPermission === 'granted' && isLogin() && checkNotificationPermissionOnce === false) {
      registerToken(settingsData?.fcmtoken)
      dispatch(isNotificationPermissionCheck({ data: { isNotificaitonPermissionChecked: true } }))
    }
    if (checkPermissions?.data?.isNotificaitonPermission === 'denied' && isLogin() && checkNotificationPermissionOnce === false) {
      registerToken('')
      dispatch(isNotificationPermissionCheck({ data: { isNotificaitonPermissionChecked: true } }))
    }
    if (checkPermissions?.data?.isLocationPermission === 'granted' && isLogin() && checkLocationPermissonOnce === false) {
      registerToken('')
      dispatch(isLocationPermissionCheck({ data: { isLocaitonPermissionChecked: true } }))
    }
  }, [isLogin(), checkPermissions])

  // Weather display component with consistent dimensions
  const WeatherDisplay = () => {
    if (!weatherMode || weatherMode !== '1') return null

    return (
      <div
        className="weather flex items-center gap-3"
        style={{ height: WEATHER_CONTAINER_HEIGHT, minWidth: '250px' }}
      >
        {weather &&
          <>
            <div>
              <div className='flex items-center gap-2'>
                <span className='me-2 weatherIcon primaryColor'>
                  <TiWeatherPartlySunny size={32} />
                </span>
                <span className='text-white font-[700] text-lg'>{weather?.current?.temp_c}°C</span>
              </div>
            </div>
            <div className='flex flex-col text-white text-[13px]'>
              <span className='font-[700]'>
                {weather?.location?.name},{' '}
                {weather?.location?.region},{' '}
                {weather?.location?.country}
              </span>
              <div className='flex items-center justify-center gap-2'>
                <div className='flex items-center'>
                  <span><HiArrowLongUp /></span>
                  <span>{maxTempC}°C</span>
                </div>
                <div className='flex items-center'>
                  <span><HiArrowLongDown /></span>
                  <span>{minTempC}°C</span>
                </div>
              </div>
            </div>
          </>}
      </div>
    )
  }

  return (
    <div className='secondaryBg py-[10px]'>
      <div className="container">
        <div className="grid grid-cols-1 md:grid-cols-2">
          <div className="leftDiv flex items-center gap-2 xl:gap-4 flex-wrap">
            <div className='date flex items-center gap-2 text-white text-[13px] font-[700] commonRadius primaryBg w-max py-1 px-2'>
              <span><SlCalender /></span>
              <span>{`${month} ${dayOfMonth}, ${year}`}</span>
            </div>
            <WeatherDisplay />
          </div>

          <div className="rightDiv xl:flex items-center justify-end gap-4 hidden">
            <ThemeToggler />
            {router.asPath === `/${currLangCode ? currLangCode : defaultLangCode}` && settingsData ? (
              <LanguageDropdown
                setMorePagesOffset={setMorePagesOffset}
                setIsLoadMorePages={setIsLoadMorePages}
              />
            ) : (
              <span className='text-white text-2xl'>|</span>
            )}
            <div style={{ height: SOCIAL_MEDIA_HEIGHT }}>
              <SocialMedias />
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default TopBar