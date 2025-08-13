import { useState } from 'react';
import styled from 'styled-components';
import { Toaster, toast } from 'react-hot-toast';
import { SearchForm } from './components/forms/SearchForm';
import { SunriseSunsetChart } from './components/charts/SunriseSunsetChart';
import { DataTable } from './components/ui/DataTable';
import { sunriseSunsetService } from './services/api';
import type { SunriseSunsetData, SearchForm as SearchFormType, ApiResponse } from './types';
import { Sun, Moon, Github, Heart } from 'lucide-react';
import { GlobalStyles } from './styles/GlobalStyles';

const AppContainer = styled.div`
  min-height: 100vh;
  padding: 2rem 1rem;

  @media (min-width: 640px) {
    padding: 2.5rem 1.5rem;
  }

  @media (min-width: 1024px) {
    padding: 3rem 2rem;
  }
`;

const MaxWidthContainer = styled.div`
  max-width: 1280px;
  margin: 0 auto;
`;

const Header = styled.header`
  text-align: center;
  margin-bottom: 3rem;

  @media (min-width: 1024px) {
    margin-bottom: 4rem;
  }
`;

const TitleContainer = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;

  @media (min-width: 640px) {
    flex-wrap: nowrap;
    gap: 1.5rem;
  }
`;

const Title = styled.h1`
  font-size: 2rem;
  font-weight: 700;
  background: linear-gradient(135deg, #f97316 0%, #ec4899 100%);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin: 0;
  text-align: center;

  @media (min-width: 640px) {
    font-size: 2.5rem;
  }

  @media (min-width: 1024px) {
    font-size: 3rem;
  }
`;

const AnimatedIcon = styled.div<{ delay?: string }>`
  animation: pulse 3s ease-in-out infinite;
  animation-delay: ${({ delay }) => delay || '0s'};
  flex-shrink: 0;

  @keyframes pulse {
    0%, 100% {
      opacity: 1;
      transform: scale(1);
    }
    50% {
      opacity: 0.7;
      transform: scale(1.1);
    }
  }
`;

const Subtitle = styled.p`
  font-size: 1rem;
  color: #6b7280;
  max-width: 800px;
  margin: 0 auto;
  line-height: 1.7;

  @media (min-width: 640px) {
    font-size: 1.125rem;
  }
`;

const ApiCredits = styled.span`
  display: block;
  font-size: 0.875rem;
  color: #9ca3af;
  margin-top: 0.75rem;
  font-style: italic;
`;

const ResultsContainer = styled.div`
  display: flex;
  flex-direction: column;
  gap: 0; /* Cards já têm margin-bottom */
  animation: fadeIn 0.6s ease-in-out;
`;

const EmptyState = styled.div`
  text-align: center;
  padding: 3rem 1.5rem;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 1rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  border: 1px solid #f3f4f6;

  @media (min-width: 1024px) {
    padding: 4rem 2rem;
  }
`;

const EmptyStateIcons = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1.5rem;
  margin-bottom: 2rem;
`;

const BouncingIcon = styled.div<{ delay?: string }>`
  animation: bounce 2s ease-in-out infinite;
  animation-delay: ${({ delay }) => delay || '0s'};
`;

const EmptyStateTitle = styled.h3`
  font-size: 1.25rem;
  font-weight: 600;
  color: #111827;
  margin-bottom: 1rem;

  @media (min-width: 640px) {
    font-size: 1.5rem;
  }
`;

const EmptyStateDescription = styled.p`
  color: #6b7280;
  max-width: 600px;
  margin: 0 auto 2rem;
  line-height: 1.6;
  font-size: 0.95rem;

  @media (min-width: 640px) {
    font-size: 1rem;
  }
`;

const FeaturesList = styled.div`
  margin-top: 2rem;
  color: #9ca3af;

  p {
    margin-bottom: 0.75rem;
    font-weight: 500;
    font-size: 0.9rem;
  }
`;

const FeaturesGrid = styled.div`
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 1rem;
  font-size: 0.75rem;

  @media (min-width: 640px) {
    gap: 1.5rem;
    font-size: 0.8rem;
  }

  span {
    padding: 0.25rem 0.5rem;
    background: rgba(249, 115, 22, 0.1);
    border-radius: 0.375rem;
    white-space: nowrap;
  }
`;

const Footer = styled.footer`
  margin-top: 3rem;
  text-align: center;
  font-size: 0.875rem;
  color: #9ca3af;
  border-top: 1px solid #e5e7eb;
  padding-top: 2rem;

  @media (min-width: 1024px) {
    margin-top: 4rem;
    padding-top: 2.5rem;
  }
`;

const FooterContent = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
  flex-wrap: wrap;
`;

const FooterLinks = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1.5rem;
  flex-wrap: wrap;

  @media (min-width: 640px) {
    gap: 2rem;
  }

  a {
    display: flex;
    align-items: center;
    gap: 0.25rem;
    color: #9ca3af;
    text-decoration: none;
    transition: color 0.2s ease;

    &:hover {
      color: #374151;
    }
  }
`;

function App() {
  const [data, setData] = useState<SunriseSunsetData[]>([]);
  const [loading, setLoading] = useState(false);
  const [meta, setMeta] = useState<ApiResponse['meta']>();

  const handleSearch = async (formData: SearchFormType) => {
    setLoading(true);
    
    try {
      const response = await sunriseSunsetService.getSunriseSunsetData(
        formData.location,
        formData.start_date,
        formData.end_date
      );

      if (response.status === 'success' && response.data) {
        setData(response.data);
        setMeta(response.meta);
        toast.success(`✅ Found data for ${response.data.length} days in ${formData.location}`, {
          duration: 3000,
          style: {
            background: '#10b981',
            color: '#fff',
            borderRadius: '12px',
            padding: '16px',
            fontSize: '14px',
            fontWeight: '500',
          },
        });
      } else {
        toast.error(`❌ ${response.message || 'Failed to fetch data'}`, {
          duration: 5000,
          style: {
            background: '#ef4444',
            color: '#fff',
            borderRadius: '12px',
            padding: '16px',
            fontSize: '14px',
            fontWeight: '500',
          },
        });
        setData([]);
        setMeta(undefined);
      }
    } catch (error) {
      console.error('Search error:', error);
      toast.error('🔌 Network error occurred. Please check if the backend is running on port 3000.', {
        duration: 6000,
        style: {
          background: '#ef4444',
          color: '#fff',
          borderRadius: '12px',
          padding: '16px',
          fontSize: '14px',
          fontWeight: '500',
        },
      });
      setData([]);
      setMeta(undefined);
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <GlobalStyles />
      <Toaster position="top-right" />
      
      <AppContainer>
        <MaxWidthContainer>
          {/* Header */}
          <Header>
            <TitleContainer>
              <AnimatedIcon>
                <Sun size={40} color="#fbbf24" />
              </AnimatedIcon>
              <Title>Sunrise Sunset App</Title>
              <AnimatedIcon delay="1.5s">
                <Moon size={40} color="#3b82f6" />
              </AnimatedIcon>
            </TitleContainer>
            <Subtitle>
              Discover sunrise, sunset, and golden hour times for any location worldwide. 
              Get historical data with beautiful visualizations and detailed tables.
              <ApiCredits>
                Powered by Open-Meteo Geocoding API and Sunrise-Sunset.io API
              </ApiCredits>
            </Subtitle>
          </Header>

          {/* Search Form */}
          <SearchForm onSubmit={handleSearch} loading={loading} />

          {/* Results */}
          {data.length > 0 && (
            <ResultsContainer>
              <SunriseSunsetChart data={data} />
              <DataTable data={data} meta={meta} />
            </ResultsContainer>
          )}

          {/* Empty State */}
          {data.length === 0 && !loading && (
            <EmptyState>
              <EmptyStateIcons>
                <BouncingIcon>
                  <Sun size={64} color="#fbbf24" />
                </BouncingIcon>
                <BouncingIcon delay="1s">
                  <Moon size={64} color="#3b82f6" />
                </BouncingIcon>
              </EmptyStateIcons>
              <EmptyStateTitle>Ready to explore solar data?</EmptyStateTitle>
              <EmptyStateDescription>
                Enter a location and date range above to get started with sunrise and sunset data.
                Try searching for cities like "Lisbon", "Berlin", "Tokyo", or even polar regions like "Svalbard".
              </EmptyStateDescription>
              <FeaturesList>
                <p>✨ Features include:</p>
                <FeaturesGrid>
                  <span>📊 Interactive Charts</span>
                  <span>📋 Detailed Tables</span>
                  <span>🌍 Global Coverage</span>
                  <span>❄️ Polar Region Support</span>
                  <span>💾 Smart Caching</span>
                </FeaturesGrid>
              </FeaturesList>
            </EmptyState>
          )}

          {/* Footer */}
          <Footer>
            <FooterContent>
              <span>Built with</span>
              <Heart size={16} color="#ef4444" />
              <span>using React, TypeScript & Ruby on Rails</span>
            </FooterContent>
            <FooterLinks>
              <a 
                href="https://github.com" 
                target="_blank"
                rel="noopener noreferrer"
              >
                <Github size={16} />
                View on GitHub
              </a>
              <span>•</span>
              <span>Jumpseller Technical Challenge</span>
            </FooterLinks>
          </Footer>
        </MaxWidthContainer>
      </AppContainer>
    </>
  );
}

export default App;