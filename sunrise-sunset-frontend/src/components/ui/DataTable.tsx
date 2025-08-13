import styled from 'styled-components';
import type { SunriseSunsetData } from '../../types';
import { format } from 'date-fns';
import { Sun, Moon, Clock, MapPin, Table } from 'lucide-react';
import { Card, CardHeader, CardBody } from './Card';

const MetaInfo = styled.div`
  background: linear-gradient(135deg, #f9fafb 0%, #f3f4f6 100%);
  border-radius: 0.75rem;
  padding: 1.5rem;
  margin-bottom: 2rem;
  border: 1px solid #e5e7eb;
`;

const MetaHeader = styled.div`
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1rem;
`;

const MetaTitle = styled.h3`
  font-size: 1.125rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
`;

const MetaStats = styled.div`
  display: flex;
  flex-wrap: wrap;
  gap: 1.5rem;
  font-size: 0.875rem;
  color: #4b5563;

  @media (max-width: 640px) {
    gap: 1rem;
    flex-direction: column;
  }
`;

const MetaStatsItem = styled.span`
  display: flex;
  align-items: center;
  gap: 0.375rem;
  font-weight: 500;
`;

const TableTitle = styled.h2`
  font-size: 1.5rem;
  font-weight: 700;
  color: #111827;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.75rem;
`;

const HeaderContent = styled.div`
  display: flex;
  align-items: center;
  gap: 0.375rem;
`;

const TableContainer = styled.div`
  overflow-x: auto;
  border-radius: 0.75rem;
  border: 1px solid #e5e7eb;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
`;

const StyledTable = styled.table`
  width: 100%;
  border-collapse: collapse;
  background: white;
  min-width: 800px;
`;

const TableHead = styled.thead`
  background: linear-gradient(135deg, #f9fafb 0%, #f3f4f6 100%);
`;

const TableHeader = styled.th`
  padding: 1rem 0.75rem;
  text-align: left;
  font-size: 0.75rem;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 2px solid #e5e7eb;
  white-space: nowrap;
  vertical-align: middle;

  &:first-child {
    padding-left: 1.5rem;
  }

  &:last-child {
    padding-right: 1.5rem;
  }
`;

const TableBody = styled.tbody``;

const TableRow = styled.tr`
  transition: all 0.2s ease;

  &:hover {
    background: linear-gradient(135deg, #fff7ed 0%, #f0f9ff 100%);
    transform: scale(1.001);
  }

  &:not(:last-child) {
    border-bottom: 1px solid #f3f4f6;
  }
`;

const TableHeaderRow = styled.tr`
  /* Styles for header row if needed */
`;

const TableCell = styled.td`
  padding: 1rem 0.75rem;
  font-size: 0.875rem;
  vertical-align: middle;

  &:first-child {
    padding-left: 1.5rem;
  }

  &:last-child {
    padding-right: 1.5rem;
  }
`;

const DateCell = styled(TableCell)`
  font-weight: 600;
  color: #1f2937;
  white-space: nowrap;
`;

const TimeCell = styled(TableCell)<{ hasValue: boolean; color?: string }>`
  color: ${({ hasValue, color }) => 
    hasValue ? (color || '#1f2937') : '#9ca3af'};
  font-weight: ${({ hasValue }) => hasValue ? '500' : '400'};
  white-space: nowrap;
  font-family: 'Menlo', 'Monaco', monospace;
`;

const DayLengthCell = styled(TableCell)`
  font-weight: 500;
  color: #374151;
  white-space: nowrap;
  font-family: 'Menlo', 'Monaco', monospace;
`;

const SpecialBadge = styled.span<{ type: 'polar-day' | 'polar-night' | 'normal' }>`
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
  padding: 0.375rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 500;
  white-space: nowrap;

  ${({ type }) => {
    switch (type) {
      case 'polar-day':
        return `
          background: #fff7ed;
          color: #c2410c;
          border: 1px solid #fed7aa;
        `;
      case 'polar-night':
        return `
          background: #f1f5f9;
          color: #475569;
          border: 1px solid #cbd5e1;
        `;
      default:
        return `
          color: #9ca3af;
          background: transparent;
        `;
    }
  }}
`;

interface Props {
  data: SunriseSunsetData[];
  meta?: {
    location: string;
    total_days: number;
    cached_records: number;
  };
}

export const DataTable = ({ data, meta }: Props) => {
  const formatTime = (time: string | null) => {
    if (!time) return 'N/A';
    return time;
  };

  const formatDate = (dateString: string) => {
    return format(new Date(dateString), 'MMM dd, yyyy');
  };

  return (
    <Card>
      <CardHeader>
        <TableTitle>
          <Table size={24} />
          Detailed Solar Data
        </TableTitle>
      </CardHeader>
      <CardBody>
        {/* Metadata */}
        {meta && (
          <MetaInfo>
            <MetaHeader>
              <MapPin size={20} color="#f97316" />
              <MetaTitle>{meta.location}</MetaTitle>
            </MetaHeader>
            <MetaStats>
              <MetaStatsItem>📅 {meta.total_days} days</MetaStatsItem>
              <MetaStatsItem>💾 {meta.cached_records} cached records</MetaStatsItem>
              <MetaStatsItem>⚡ {meta.total_days - meta.cached_records} new fetches</MetaStatsItem>
            </MetaStats>
          </MetaInfo>
        )}

        <TableContainer>
          <StyledTable>
            <TableHead>
              <TableHeaderRow>
                <TableHeader>
                  <HeaderContent>Date</HeaderContent>
                </TableHeader>
                <TableHeader>
                  <HeaderContent>
                    <Sun size={16} />
                    Sunrise
                  </HeaderContent>
                </TableHeader>
                <TableHeader>
                  <HeaderContent>
                    <Moon size={16} />
                    Sunset
                  </HeaderContent>
                </TableHeader>
                <TableHeader>
                  <HeaderContent>
                    <Clock size={16} />
                    Golden Hour
                  </HeaderContent>
                </TableHeader>
                <TableHeader>
                  <HeaderContent>Day Length</HeaderContent>
                </TableHeader>
                <TableHeader>
                  <HeaderContent>Special</HeaderContent>
                </TableHeader>
              </TableHeaderRow>
            </TableHead>
            <TableBody>
              {data.map((item: SunriseSunsetData) => (
                <TableRow key={item.id}>
                  <DateCell>{formatDate(item.date)}</DateCell>
                  
                  <TimeCell hasValue={!!item.sunrise} color="#fbbf24">
                    {formatTime(item.sunrise)}
                  </TimeCell>
                  
                  <TimeCell hasValue={!!item.sunset} color="#ef4444">
                    {formatTime(item.sunset)}
                  </TimeCell>
                  
                  <TimeCell hasValue={!!item.golden_hour} color="#f59e0b">
                    {formatTime(item.golden_hour)}
                  </TimeCell>
                  
                  <DayLengthCell>
                    {item.day_length_formatted || 'N/A'}
                  </DayLengthCell>
                  
                  <TableCell>
                    {item.polar_day && (
                      <SpecialBadge type="polar-day">
                        ☀️ Polar Day
                      </SpecialBadge>
                    )}
                    {item.polar_night && (
                      <SpecialBadge type="polar-night">
                        🌙 Polar Night
                      </SpecialBadge>
                    )}
                    {!item.polar_day && !item.polar_night && (
                      <SpecialBadge type="normal">Normal</SpecialBadge>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </StyledTable>
        </TableContainer>
      </CardBody>
    </Card>
  );
};