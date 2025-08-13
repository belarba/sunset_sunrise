import styled, { css } from 'styled-components';

interface InputProps {
  hasError?: boolean;
}

export const InputGroup = styled.div`
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  width: 100%;
`;

export const Label = styled.label`
  font-size: 0.875rem;
  font-weight: 500;
  color: #374151;
  display: flex;
  align-items: center;
  gap: 0.25rem;
  transition: color 0.2s ease;
`;

export const Input = styled.input<InputProps>`
  width: 100%;
  padding: 0.75rem 1rem;
  border: 2px solid #e5e7eb;
  border-radius: 0.75rem;
  font-size: 1rem;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  transition: all 0.2s ease;
  color: #1f2937;

  &:focus {
    outline: none;
    border-color: #f97316;
    box-shadow: 0 0 0 3px rgba(249, 115, 22, 0.1);
    transform: scale(1.01);
    background: rgba(255, 255, 255, 1);
  }

  &::placeholder {
    color: #9ca3af;
    font-size: 0.9rem;
  }

  ${({ hasError }) =>
    hasError &&
    css`
      border-color: #ef4444;
      
      &:focus {
        border-color: #ef4444;
        box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
      }
    `}

  &:disabled {
    background: #f9fafb;
    border-color: #d1d5db;
    color: #6b7280;
    cursor: not-allowed;
  }
`;

export const ErrorMessage = styled.span`
  font-size: 0.875rem;
  color: #ef4444;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 0.25rem;
`;

export const HelperText = styled.span`
  font-size: 0.75rem;
  color: #6b7280;
  line-height: 1.4;
`;