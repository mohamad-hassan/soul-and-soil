import { translate } from '@/utils/helpers';
import React, { useEffect } from 'react';
import { FaChevronLeft, FaChevronRight } from 'react-icons/fa';

const DateTabContent = ({
  setDate,
  setLastNDays,
  displayDate,
  setDisplayDate,
  selectedDate,
  setSelectedDate,
  activeDateTab,
  setActiveDateTab,
  offset
}) => {
  const currentDate = new Date();

  // Generate days for the calendar
  const generateCalendarDays = () => {
    const year = displayDate.getFullYear();
    const month = displayDate.getMonth();

    // First day of the month
    const firstDay = new Date(year, month, 1).getDay();
    // Adjust for Monday as first day (0 = Monday, 6 = Sunday)
    const adjustedFirstDay = firstDay === 0 ? 6 : firstDay - 1;

    // Last day of the month
    const lastDay = new Date(year, month + 1, 0).getDate();

    // Days from previous month
    const prevMonthLastDay = new Date(year, month, 0).getDate();

    const days = [];

    // Add days from previous month
    for (let i = adjustedFirstDay - 1; i >= 0; i--) {
      days.push({
        day: prevMonthLastDay - i,
        month: month - 1,
        year: month === 0 ? year - 1 : year,
        isCurrentMonth: false
      });
    }

    // Add days from current month
    for (let i = 1; i <= lastDay; i++) {
      days.push({
        day: i,
        month,
        year,
        isCurrentMonth: true
      });
    }

    // Add days from next month
    const remainingDays = 42 - days.length; // 6 rows of 7 days
    for (let i = 1; i <= remainingDays; i++) {
      days.push({
        day: i,
        month: month + 1,
        year: month === 11 ? year + 1 : year,
        isCurrentMonth: false
      });
    }

    return days;
  };

  const days = generateCalendarDays();

  // Navigate to previous/next month
  const goToPreviousMonth = () => {
    setDisplayDate(new Date(displayDate.getFullYear(), displayDate.getMonth() - 1, 1));
  };

  const goToNextMonth = () => {
    setDisplayDate(new Date(displayDate.getFullYear(), displayDate.getMonth() + 1, 1));
  };

  // Check if a date is the selected date
  const isSelectedDate = (date) => {
    return date.day === selectedDate.getDate() &&
      date.month === selectedDate.getMonth() &&
      date.year === selectedDate.getFullYear();
  };

  // Handle date selection
  const handleDateSelect = (date) => {
    setDate({
      date: `${date.year}-${date.month + 1}-${date.day}`,
      year: date.year
    });
    setSelectedDate(new Date(date.year, date.month, date.day));
    setActiveDateTab('custom');
  };

  // Handle tab selection
  const handleTabSelect = (tab) => {
    setActiveDateTab(tab);

    const today = new Date();

    switch (tab) {
      case 'today':
        setDate({
          date: today,
          year: today.getFullYear()
        });
        setSelectedDate(today);
        break;
      case 'last7days':
        setLastNDays(7);
        break;
      case 'last30days':
        setLastNDays(30);
        break;
      case 'last90days':
        setLastNDays(90);
        break;
      case currentDate.getFullYear():
        setDate({
          date: '',
          year: currentDate.getFullYear()
        });
        break;
      case currentDate.getFullYear() - 1:
        setDate({
          date: '',
          year: currentDate.getFullYear() - 1
        });
        break;
      case currentDate.getFullYear() - 2:
        setDate({
          date: '',
          year: currentDate.getFullYear() - 2
        });
        break;
      default:
        break;
    }
  };

  // Format month and year display
  const monthYearDisplay = () => {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return `${months[displayDate.getMonth()]}`;
  };

  return (
    <div className="flex flex-col md:flex-row rounded-lg bg-[#F5F5F5] shadow-sm overflow-hidden font-medium h-[300px] overflow-y-auto sm:h-max">
      {/* Left sidebar with quick date options */}
      <div className="w-full md:w-40 p-4 border-r border-gray-200 text-[#1B2D51]">
        <div className="space-y-2">
          <button
            onClick={() => handleTabSelect('today')}
            className={`w-full text-left px-3 py-2 rounded-md ${activeDateTab === 'today' ? 'bg-[#1B2D511A]' : 'hover:bg-[#1B2D511A]'}`}
          >
            {translate('today')}
          </button>
          <button
            onClick={() => handleTabSelect('last7days')}
            className={`w-full text-left px-3 py-2 rounded-md ${activeDateTab === 'last7days' ? 'bg-[#1B2D511A]' : 'hover:bg-[#1B2D511A]'}`}
          >
            {translate('last7days')}
          </button>
          <button
            onClick={() => handleTabSelect('last30days')}
            className={`w-full text-left px-3 py-2 rounded-md ${activeDateTab === 'last30days' ? 'bg-[#1B2D511A]' : 'hover:bg-[#1B2D511A]'}`}
          >
            {translate('last30days')}
          </button>
          <button
            onClick={() => handleTabSelect('last90days')}
            className={`w-full text-left px-3 py-2 rounded-md ${activeDateTab === 'last90days' ? 'bg-[#1B2D511A]' : 'hover:bg-[#1B2D511A]'}`}
          >
            {translate('last90days')}
          </button>
          <button
            onClick={() => handleTabSelect(currentDate.getFullYear())}
            className={`w-full text-left px-3 py-2 rounded-md ${activeDateTab === currentDate.getFullYear() ? 'bg-[#1B2D511A]' : 'hover:bg-[#1B2D511A]'}`}
          >
            {currentDate.getFullYear()}
          </button>
          <button
            onClick={() => handleTabSelect(currentDate.getFullYear() - 1)}
            className={`w-full text-left px-3 py-2 rounded-md ${activeDateTab === currentDate.getFullYear() - 1 ? 'bg-[#1B2D511A]' : 'hover:bg-[#1B2D511A]'}`}
          >
            {currentDate.getFullYear() - 1}
          </button>
          <button
            onClick={() => handleTabSelect(currentDate.getFullYear() - 2)}
            className={`w-full text-left px-3 py-2 rounded-md ${activeDateTab === currentDate.getFullYear() - 2 ? 'bg-[#1B2D511A]' : 'hover:bg-[#1B2D511A]'}`}
          >
            {currentDate.getFullYear() - 2}
          </button>
        </div>
      </div>

      {/* Calendar view */}
      <div className="flex-1 p-4 text-[#1B2D51]">
        <div className="mb-4 flex justify-between items-center">
          {/* <button 
            onClick={goToPreviousMonth} 
            className="p-2 rounded-full hover:bg-[#1B2D511A]"
          >
            <FaChevronLeft />
          </button> */}
          <div className="flex items-center justify-between w-full gap-3">
            <div className="text-lg font-bold py-1 rounded-[6px] bg-white w-full text-center">{monthYearDisplay()}</div>
            <div className="text-lg font-bold py-1 rounded-[6px] bg-white w-full text-center">{displayDate.getFullYear()}</div>
          </div>
          {/* <button 
            onClick={goToNextMonth} 
            className="p-2 rounded-full hover:bg-[#1B2D511A]"
          >
            <FaChevronRight />
          </button> */}
        </div>

        {/* Days of week headers */}
        <div className="grid grid-cols-7 mb-2">
          {['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'].map((day, index) => (
            <div key={day} className="text-center text-sm font-medium py-2">
              {day}
            </div>
          ))}
        </div>

        {/* Calendar grid */}
        <div className="grid grid-cols-7 gap-2">
          {days.map((date, index) => {
            const isDateAfterToday = new Date(date.year, date.month, date.day) > new Date(
              new Date().getFullYear(),
              new Date().getMonth(),
              new Date().getDate()
            );
            
            return (
              <button
                key={index}
                onClick={() => handleDateSelect(date)}
                disabled={isDateAfterToday}
                className={`
                  h-10 w-full flex items-center justify-center rounded-md text-sm sm:text-base
                  ${!date.isCurrentMonth ? 'text-gray-300' : isDateAfterToday ? '!cursor-not-allowed !bg-white' : 'text-gray-800 shadow'}
                  ${isSelectedDate(date) ? 'bg-[#1B2D51] text-white' : isDateAfterToday ? 'bg-gray-100' : 'bg-white hover:bg-[#1B2D51] hover:text-white transition-all duration-300'}
                `}
              >
                {String(date.day).padStart(2, '0')}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default DateTabContent;
