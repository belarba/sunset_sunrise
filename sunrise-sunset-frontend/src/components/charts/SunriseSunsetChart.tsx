import styled from 'styled-components';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  type ChartOptions,
  type TooltipItem,
} from 'chart.js';
import { Line } from 'react-chartjs-2';
import type { SunriseSunsetData } from '../../types';
import { format } from 'date-fns';
import { Card, CardHeader, CardBody } from '../ui/Card';
import { BarChart3 } from 'lucide-react';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

const ChartContainer = styled.div`
  height: 400px;
  position: relative;
  background: linear-gradient(135deg, #fff7ed 0%, #ffffff 50%, #f0f9ff 100%);
  border-radius: 0.75rem;
  padding: 1rem;

  @media (min-width: 1024px) {
    height: 500px;
    padding: 1.5rem;
  }
`;

const LegendContainer = styled.div`
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 2rem;
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.7);
  border-radius: 0.5rem;
  border: 1px solid #f3f4f6;
`;

const LegendItem = styled.div<{ color: string }>`
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: #4b5563;
  font-weight: 500;

  &::before {
    content: '';
    width: 16px;
    height: 4px;
    background: ${({ color }) => color};
    border-radius: 0.25rem;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  }
`;

const ChartTitle = styled.h2`
  font-size: 1.5rem;
  font-weight: 700;
  color: #111827;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.75rem;
`;

interface Props {
  data: SunriseSunsetData[];
}

export const SunriseSunsetChart = ({ data }: Props) => {
  const timeToMinutes = (timeString: string | null): number | null => {
    if (!timeString) return null;
    const [hours, minutes, seconds] = timeString.split(':').map(Number);
    return hours * 60 + minutes + (seconds ? seconds / 60 : 0);
  };

  const formatMinutesToTime = (minutes: number): string => {
    const hours = Math.floor(minutes / 60);
    const mins = Math.floor(minutes % 60);
    return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
  };

  const chartData = {
    labels: data.map((item: SunriseSunsetData) => format(new Date(item.date), 'MMM dd')),
    datasets: [
      {
        label: 'Sunrise',
        data: data.map((item: SunriseSunsetData) => timeToMinutes(item.sunrise)),
        borderColor: '#fbbf24',
        backgroundColor: 'rgba(251, 191, 36, 0.1)',
        tension: 0.4,
        spanGaps: false,
        pointBackgroundColor: '#fbbf24',
        pointBorderColor: '#ffffff',
        pointBorderWidth: 2,
        pointRadius: 5,
        pointHoverRadius: 8,
        borderWidth: 3,
      },
      {
        label: 'Sunset',
        data: data.map((item: SunriseSunsetData) => timeToMinutes(item.sunset)),
        borderColor: '#ef4444',
        backgroundColor: 'rgba(239, 68, 68, 0.1)',
        tension: 0.4,
        spanGaps: false,
        pointBackgroundColor: '#ef4444',
        pointBorderColor: '#ffffff',
        pointBorderWidth: 2,
        pointRadius: 5,
        pointHoverRadius: 8,
        borderWidth: 3,
      },
      {
        label: 'Golden Hour',
        data: data.map((item: SunriseSunsetData) => timeToMinutes(item.golden_hour)),
        borderColor: '#f59e0b',
        backgroundColor: 'rgba(245, 158, 11, 0.1)',
        tension: 0.4,
        spanGaps: false,
        pointBackgroundColor: '#f59e0b',
        pointBorderColor: '#ffffff',
        pointBorderWidth: 2,
        pointRadius: 5,
        pointHoverRadius: 8,
        borderWidth: 3,
      },
    ],
  };

  const options: ChartOptions<'line'> = {
    responsive: true,
    maintainAspectRatio: false,
    interaction: {
      intersect: false,
      mode: 'index' as const,
    },
    plugins: {
      legend: {
        display: false, // Using custom legend
      },
      title: {
        display: false,
      },
      tooltip: {
        backgroundColor: 'rgba(0, 0, 0, 0.9)',
        titleColor: '#ffffff',
        bodyColor: '#ffffff',
        borderColor: 'rgba(249, 115, 22, 0.3)',
        borderWidth: 1,
        cornerRadius: 12,
        padding: 12,
        titleFont: {
          size: 14,
          weight: 'bold' as const,
        },
        bodyFont: {
          size: 13,
        },
        callbacks: {
          label: function(context: TooltipItem<'line'>) {
            const label = context.dataset.label || '';
            const value = context.parsed.y;
            if (value === null) return `${label}: No data (Polar region)`;
            return `${label}: ${formatMinutesToTime(value)}`;
          },
        },
      },
    },
    scales: {
      y: {
        type: 'linear' as const,
        title: {
          display: true,
          text: 'Time of Day',
          color: '#6b7280',
          font: {
            size: 14,
            weight: 'bold' as const,
          },
        },
        ticks: {
          callback: function(value: string | number) {
            return formatMinutesToTime(Number(value));
          },
          stepSize: 60, // 1 hour steps
          color: '#6b7280',
          font: {
            size: 12,
          },
        },
        grid: {
          color: 'rgba(107, 114, 128, 0.2)',
        },
        border: {
          display: false,
        },
        min: 0,
        max: 1440, // 24 hours
      },
      x: {
        title: {
          display: true,
          text: 'Date',
          color: '#6b7280',
          font: {
            size: 14,
            weight: 'bold' as const,
          },
        },
        ticks: {
          color: '#6b7280',
          font: {
            size: 12,
          },
        },
        grid: {
          color: 'rgba(107, 114, 128, 0.1)',
        },
        border: {
          display: false,
        },
      },
    },
  };

  return (
    <Card>
      <CardHeader>
        <ChartTitle>
          <BarChart3 size={24} />
          Sunrise, Sunset & Golden Hour Timeline
        </ChartTitle>
      </CardHeader>
      <CardBody>
        {/* Custom Legend */}
        <LegendContainer>
          <LegendItem color="#fbbf24">
            Sunrise
          </LegendItem>
          <LegendItem color="#ef4444">
            Sunset
          </LegendItem>
          <LegendItem color="#f59e0b">
            Golden Hour
          </LegendItem>
        </LegendContainer>

        <ChartContainer>
          <Line data={chartData} options={options} />
        </ChartContainer>
      </CardBody>
    </Card>
  );
};