import styled, { css } from 'styled-components';

interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'outline';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  loading?: boolean;
}

const buttonVariants = {
  primary: css`
    background: #f97316;
    color: #ffffff;
    border: 2px solid #f97316;

    &:hover:not(:disabled) {
      background: #ea580c;
      border-color: #ea580c;
      transform: translateY(-2px);
      box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
    }

    &:active:not(:disabled) {
      transform: translateY(0);
    }
  `,
  secondary: css`
    background: #f3f4f6;
    color: #374151;
    border: 2px solid #e5e7eb;

    &:hover:not(:disabled) {
      background: #e5e7eb;
      color: #1f2937;
      transform: translateY(-1px);
    }
  `,
  outline: css`
    background: transparent;
    color: #ea580c;
    border: 2px solid #fed7aa;

    &:hover:not(:disabled) {
      background: #fff7ed;
      border-color: #f97316;
      color: #c2410c;
    }
  `,
};

const buttonSizes = {
  sm: css`
    padding: 0.5rem 1rem;
    font-size: 0.875rem;
    gap: 0.375rem;
  `,
  md: css`
    padding: 0.75rem 1.5rem;
    font-size: 1rem;
    gap: 0.5rem;
  `,
  lg: css`
    padding: 1rem 2rem;
    font-size: 1.125rem;
    gap: 0.5rem;
  `,
};

export const Button = styled.button<ButtonProps>`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 0.75rem;
  font-weight: 600;
  transition: all 0.2s ease;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  white-space: nowrap;

  ${({ variant = 'primary' }) => buttonVariants[variant]}
  ${({ size = 'md' }) => buttonSizes[size]}

  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    transform: none !important;
  }

  &:focus {
    outline: none;
    box-shadow: 0 0 0 3px rgba(249, 115, 22, 0.1);
  }

  ${({ loading }) =>
    loading &&
    css`
      color: transparent;

      &::after {
        content: '';
        position: absolute;
        width: 20px;
        height: 20px;
        border: 2px solid transparent;
        border-top: 2px solid currentColor;
        border-radius: 50%;
        animation: spin 1s linear infinite;
      }
    `}
`;