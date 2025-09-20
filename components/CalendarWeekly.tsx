'use client';

import React, { useState, useEffect } from 'react';
import { ChevronLeft, ChevronRight, Calendar, Clock, Users, Euro } from 'lucide-react';

interface Reservation {
  id: string;
  reservation_number: string;
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  room_name: string;
  date: string;
  time: string;
  duration: number;
  number_of_people: number;
  status: 'pending' | 'confirmed' | 'cancelled';
  amount: number;
  notes?: string;
  created_at: string;
  updated_at: string;
}

interface WeeklyData {
  week: {
    start: string;
    end: string;
    startDate: Date;
    endDate: Date;
  };
  reservations: { [key: string]: Reservation[] };
  statistics: {
    total: number;
    confirmed: number;
    pending: number;
    cancelled: number;
    revenue: number;
  };
}

/**
 * Composant CalendarWeekly - Calendrier hebdomadaire avec réservations
 * Affiche les réservations de la semaine avec navigation et statistiques
 */
export default function CalendarWeekly() {
  const [currentWeek, setCurrentWeek] = useState(new Date());
  const [weeklyData, setWeeklyData] = useState<WeeklyData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Noms des jours de la semaine
  const dayNames = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  const dayNamesShort = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  /**
   * Récupère les réservations de la semaine courante
   */
  const fetchWeeklyReservations = async (weekDate: Date) => {
    try {
      setLoading(true);
      setError(null);
      
      const weekParam = weekDate.toISOString().split('T')[0];
      const response = await fetch(`/api/admin/reservations/weekly?week=${weekParam}`);
      
      if (!response.ok) {
        throw new Error('Erreur lors de la récupération des réservations');
      }
      
      const data = await response.json();
      setWeeklyData(data);
    } catch (err) {
      console.error('Erreur:', err);
      setError(err instanceof Error ? err.message : 'Erreur inconnue');
    } finally {
      setLoading(false);
    }
  };

  /**
   * Navigation vers la semaine précédente
   */
  const goToPreviousWeek = () => {
    const newWeek = new Date(currentWeek);
    newWeek.setDate(newWeek.getDate() - 7);
    setCurrentWeek(newWeek);
    fetchWeeklyReservations(newWeek);
  };

  /**
   * Navigation vers la semaine suivante
   */
  const goToNextWeek = () => {
    const newWeek = new Date(currentWeek);
    newWeek.setDate(newWeek.getDate() + 7);
    setCurrentWeek(newWeek);
    fetchWeeklyReservations(newWeek);
  };

  /**
   * Retour à la semaine courante
   */
  const goToCurrentWeek = () => {
    const today = new Date();
    setCurrentWeek(today);
    fetchWeeklyReservations(today);
  };

  /**
   * Génère les dates de la semaine courante
   */
  const getWeekDates = (weekDate: Date) => {
    const dates = [];
    const startOfWeek = new Date(weekDate);
    const dayOfWeek = startOfWeek.getDay();
    const daysToMonday = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
    startOfWeek.setDate(startOfWeek.getDate() + daysToMonday);
    
    for (let i = 0; i < 7; i++) {
      const date = new Date(startOfWeek);
      date.setDate(date.getDate() + i);
      dates.push(date);
    }
    
    return dates;
  };

  /**
   * Formate l'heure pour l'affichage
   */
  const formatTime = (time: string) => {
    return time.substring(0, 5); // HH:MM
  };

  /**
   * Obtient la couleur du statut
   */
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'confirmed':
        return 'bg-green-100 text-green-800 border-green-200';
      case 'pending':
        return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case 'cancelled':
        return 'bg-red-100 text-red-800 border-red-200';
      default:
        return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  /**
   * Obtient le texte du statut en français
   */
  const getStatusText = (status: string) => {
    switch (status) {
      case 'confirmed':
        return 'Confirmée';
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  };

  // Charger les données au montage du composant
  useEffect(() => {
    fetchWeeklyReservations(currentWeek);
  }, []);

  const weekDates = getWeekDates(currentWeek);
  const today = new Date();
  const isCurrentWeek = weekDates.some(date => 
    date.toDateString() === today.toDateString()
  );

  if (loading) {
    return (
      <div className="bg-dark-surface border border-kaki-800/30 rounded-lg p-6">
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-kaki-500"></div>
          <span className="ml-3 text-kaki-300">Chargement du calendrier...</span>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-dark-surface border border-kaki-800/30 rounded-lg p-6">
        <div className="text-center">
          <div className="text-red-400 mb-2">⚠️ Erreur</div>
          <p className="text-kaki-300">{error}</p>
          <button
            onClick={() => fetchWeeklyReservations(currentWeek)}
            className="mt-4 px-4 py-2 bg-kaki-600 text-white rounded-lg hover:bg-kaki-700 transition-colors"
          >
            Réessayer
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-gray-800 border border-gray-700 rounded-lg">
      {/* En-tête avec navigation */}
      <div className="p-6 border-b border-gray-700">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Calendar className="h-6 w-6 text-kaki-400" />
            <h2 className="text-xl font-semibold text-white">
              Calendrier Hebdomadaire
            </h2>
          </div>
          
          <div className="flex items-center space-x-2">
            <button
              onClick={goToPreviousWeek}
              className="p-2 text-gray-400 hover:text-white hover:bg-gray-700 rounded-lg transition-colors"
              title="Semaine précédente"
            >
              <ChevronLeft className="h-5 w-5" />
            </button>
            
            <button
              onClick={goToCurrentWeek}
              className={`px-3 py-1 text-sm rounded-lg transition-colors ${
                isCurrentWeek 
                  ? 'bg-kaki-600 text-white' 
                  : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
              }`}
            >
              Aujourd'hui
            </button>
            
            <button
              onClick={goToNextWeek}
              className="p-2 text-gray-400 hover:text-white hover:bg-gray-700 rounded-lg transition-colors"
              title="Semaine suivante"
            >
              <ChevronRight className="h-5 w-5" />
            </button>
          </div>
        </div>

        {/* Période de la semaine */}
        <div className="mt-4 text-gray-300">
          {weeklyData && (
            <p>
              Semaine du {new Date(weeklyData.week.start).toLocaleDateString('fr-FR', {
                day: 'numeric',
                month: 'long'
              })} au {new Date(weeklyData.week.end).toLocaleDateString('fr-FR', {
                day: 'numeric',
                month: 'long',
                year: 'numeric'
              })}
            </p>
          )}
        </div>
      </div>

      {/* Statistiques de la semaine */}
      {weeklyData && (
        <div className="p-6 border-b border-gray-700">
          <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
            <div className="bg-gray-700 border border-gray-600 rounded-lg p-4">
              <div className="flex items-center">
                <Calendar className="h-5 w-5 text-kaki-400 mr-2" />
                <div>
                  <p className="text-sm text-gray-400">Total</p>
                  <p className="text-lg font-semibold text-white">{weeklyData.statistics.total}</p>
                </div>
              </div>
            </div>
            
            <div className="bg-gray-700 border border-gray-600 rounded-lg p-4">
              <div className="flex items-center">
                <div className="h-5 w-5 bg-green-400 rounded-full mr-2"></div>
                <div>
                  <p className="text-sm text-gray-400">Confirmées</p>
                  <p className="text-lg font-semibold text-white">{weeklyData.statistics.confirmed}</p>
                </div>
              </div>
            </div>
            
            <div className="bg-gray-700 border border-gray-600 rounded-lg p-4">
              <div className="flex items-center">
                <div className="h-5 w-5 bg-yellow-400 rounded-full mr-2"></div>
                <div>
                  <p className="text-sm text-gray-400">En attente</p>
                  <p className="text-lg font-semibold text-white">{weeklyData.statistics.pending}</p>
                </div>
              </div>
            </div>
            
            <div className="bg-gray-700 border border-gray-600 rounded-lg p-4">
              <div className="flex items-center">
                <div className="h-5 w-5 bg-red-400 rounded-full mr-2"></div>
                <div>
                  <p className="text-sm text-gray-400">Annulées</p>
                  <p className="text-lg font-semibold text-white">{weeklyData.statistics.cancelled}</p>
                </div>
              </div>
            </div>
            
            <div className="bg-gray-700 border border-gray-600 rounded-lg p-4">
              <div className="flex items-center">
                <Euro className="h-5 w-5 text-green-400 mr-2" />
                <div>
                  <p className="text-sm text-gray-400">Revenus</p>
                  <p className="text-lg font-semibold text-white">{Math.round(weeklyData.statistics.revenue)}€</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Calendrier hebdomadaire */}
      <div className="p-6">
        <div className="grid grid-cols-7 gap-4">
          {weekDates.map((date, index) => {
            const dateKey = date.toISOString().split('T')[0];
            const isToday = date.toDateString() === today.toDateString();
            const dayReservations = weeklyData?.reservations[dateKey] || [];
            
            return (
              <div key={index} className="min-h-[200px]">
                {/* En-tête du jour */}
                <div className={`text-center p-3 rounded-lg mb-3 ${
                  isToday 
                    ? 'bg-kaki-600 text-white' 
                    : 'bg-gray-700 border border-gray-600 text-gray-300'
                }`}>
                  <div className="text-sm font-medium">{dayNamesShort[index]}</div>
                  <div className="text-lg font-bold">{date.getDate()}</div>
                </div>

                {/* Réservations du jour */}
                <div className="space-y-2">
                  {dayReservations.length === 0 ? (
                    <div className="text-center text-gray-500 text-sm py-4">
                      Aucune réservation
                    </div>
                  ) : (
                    dayReservations.map((reservation) => (
                      <div
                        key={reservation.id}
                        className={`p-3 rounded-lg border text-xs ${
                          getStatusColor(reservation.status)
                        }`}
                      >
                        <div className="font-medium mb-1">
                          {reservation.first_name} {reservation.last_name}
                        </div>
                        
                        <div className="space-y-1 text-xs">
                          <div className="flex items-center">
                            <Clock className="h-3 w-3 mr-1" />
                            {formatTime(reservation.time)}
                          </div>
                          
                          <div className="flex items-center">
                            <Users className="h-3 w-3 mr-1" />
                            {reservation.number_of_people} pers.
                          </div>
                          
                          <div className="font-medium">
                            {reservation.room_name}
                          </div>
                          
                          <div className={`inline-block px-2 py-1 rounded text-xs font-medium ${
                            getStatusColor(reservation.status)
                          }`}>
                            {getStatusText(reservation.status)}
                          </div>
                        </div>
                      </div>
                    ))
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
