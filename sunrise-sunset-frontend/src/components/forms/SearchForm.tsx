import { useState, useEffect } from 'react';
import styled from 'styled-components';
import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as yup from 'yup';
import { format, addYears, addDays } from 'date-fns';
import { Search, MapPin, Calendar, Loader2 } from 'lucide-react';
import type { SearchForm as SearchFormType } from '../../types';
import { sunriseSunsetService } from '../../services/api';
import { Card, CardHeader, CardBody } from '../ui/Card';
import { Button } from '../ui/Button';
import { Input, InputGroup, Label, ErrorMessage } from '../ui/Input';

const FormContainer = styled.form`
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
`;

const FormRow = styled.div`
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.5rem;

  @media (min-width: 768px) {
    grid-template-columns: 1fr 1fr;
  }
`;

const RecentLocations = styled.div`
  margin-top: 0.75rem;
`;

const RecentLocationsLabel = styled.p`
  font-size: 0.75rem;
  color: #6b7280;
  margin-bottom: 0.5rem;
  font-weight: 500;
`;

const FormTitle = styled.h2`
  font-size: 1.5rem;
  font-weight: 700;
  color: #111827;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.75rem;
`;

const HelperText = styled.div`
  font-size: 0.875rem;
  color: #6b7280;
  text-align: center;
  font-style: italic;
  margin-top: -1rem;
`;

const LocationTags = styled.div`
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
`;

const LocationTag = styled.button`
  padding: 0.375rem 0.75rem;
  font-size: 0.75rem;
  background: #f3f4f6;
  color: #4b5563;
  border: 1px solid #e5e7eb;
  border-radius: 9999px;
  transition: all 0.2s ease;
  font-weight: 500;

  &:hover {
    background: #e5e7eb;
    color: #374151;
    transform: translateY(-1px);
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }

  &:active {
    transform: translateY(0);
  }
`;

const FullWidthButton = styled(Button)`
  width: 100%;
  justify-content: center;
  font-size: 1rem;
  padding: 1rem;
`;

const schema = yup.object({
  location: yup
    .string()
    .required('Location is required')
    .min(2, 'Location must be at least 2 characters'),
  start_date: yup.string().required('Start date is required'),
  end_date: yup.string().required('End date is required')
    .test('date-range', 'End date must be after start date', function(value) {
      const { start_date } = this.parent;
      if (!start_date || !value) return true;
      return new Date(value) >= new Date(start_date);
    })
    .test('minimum-days', 'Please select at least 2 days (end date must be at least 1 day after start date)', function(value) {
      const { start_date } = this.parent;
      if (!start_date || !value) return true;
      const startDate = new Date(start_date);
      const endDate = new Date(value);
      const diffTime = endDate.getTime() - startDate.getTime();
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
      return diffDays >= 1; // Pelo menos 1 dia de diferença (= 2 dias total)
    }),
});

interface Props {
  onSubmit: (data: SearchFormType) => void;
  loading: boolean;
}

export const SearchForm = ({ onSubmit, loading }: Props) => {
  const [recentLocations, setRecentLocations] = useState<string[]>([]);

  const {
    register,
    handleSubmit,
    setValue,
    watch,
    formState: { errors },
  } = useForm<SearchFormType>({
    resolver: yupResolver(schema),
    defaultValues: {
      location: '',
      start_date: format(new Date(), 'yyyy-MM-dd'), // Hoje
      end_date: format(addDays(new Date(), 6), 'yyyy-MM-dd'), // 7 dias (hoje + 6)
    },
  });

  const watchedStartDate = watch('start_date');

  useEffect(() => {
    const fetchRecentLocations = async () => {
      const locations = await sunriseSunsetService.getRecentLocations();
      setRecentLocations(locations);
    };
    fetchRecentLocations();
  }, []);

  const handleLocationSelect = (location: string) => {
    setValue('location', location);
  };

  return (
    <Card>
      <CardHeader>
        <FormTitle>
          <Search size={24} />
          Search Sunrise & Sunset Data
        </FormTitle>
      </CardHeader>
      <CardBody>
        <FormContainer onSubmit={handleSubmit(onSubmit)}>
          {/* Location Input */}
          <InputGroup>
            <Label htmlFor="location">
              <MapPin size={16} />
              Location
            </Label>
            <Input
              {...register('location')}
              id="location"
              type="text"
              placeholder="Enter city name (e.g., Lisbon, Berlin, New York)"
              hasError={!!errors.location}
            />
            {errors.location && (
              <ErrorMessage>{errors.location.message}</ErrorMessage>
            )}

            {/* Recent Locations */}
            {recentLocations.length > 0 && (
              <RecentLocations>
                <RecentLocationsLabel>Recent locations:</RecentLocationsLabel>
                <LocationTags>
                  {recentLocations.slice(0, 5).map((location: string) => (
                    <LocationTag
                      key={location}
                      type="button"
                      onClick={() => handleLocationSelect(location)}
                    >
                      {location}
                    </LocationTag>
                  ))}
                </LocationTags>
              </RecentLocations>
            )}
          </InputGroup>

          {/* Date Range Helper */}
          <HelperText>
            💡 Minimum 2 days required for timeline visualization
          </HelperText>

          {/* Date Inputs */}
          <FormRow>
            <InputGroup>
              <Label htmlFor="start_date">
                <Calendar size={16} />
                Start Date
              </Label>
              <Input
                {...register('start_date')}
                id="start_date"
                type="date"
                hasError={!!errors.start_date}
                max={format(new Date(), 'yyyy-MM-dd')}
                min="1900-01-01"
              />
              {errors.start_date && (
                <ErrorMessage>{errors.start_date.message}</ErrorMessage>
              )}
            </InputGroup>

            <InputGroup>
              <Label htmlFor="end_date">
                <Calendar size={16} />
                End Date
              </Label>
              <Input
                {...register('end_date')}
                id="end_date"
                type="date"
                hasError={!!errors.end_date}
                min={watchedStartDate ? (() => {
                  try {
                    return format(addDays(new Date(watchedStartDate), 1), 'yyyy-MM-dd');
                  } catch {
                    return undefined;
                  }
                })() : undefined}
                max={format(addYears(new Date(), 1), 'yyyy-MM-dd')} // Permitir até 1 ano no futuro
              />
              {errors.end_date && (
                <ErrorMessage>{errors.end_date.message}</ErrorMessage>
              )}
            </InputGroup>
          </FormRow>

          {/* Submit Button */}
          <FullWidthButton
            type="submit"
            disabled={loading}
            loading={loading}
            size="lg"
          >
            {loading ? (
              <>
                <Loader2 size={20} />
                Searching...
              </>
            ) : (
              <>
                <Search size={20} />
                Get Sunrise & Sunset Data
              </>
            )}
          </FullWidthButton>
        </FormContainer>
      </CardBody>
    </Card>
  );
};