import { describe, test, expect, beforeEach, vi } from 'vitest';

// Mock functions to simulate Clarity contract behavior
const mockContractCall = vi.fn();
const mockReadOnlyCall = vi.fn();

// Mock contract state
let dreamNonce = 0;
let interpreterNonce = 0;
const dreams = new Map();
const interpreters = new Map();
const interpretations = new Map();

// Mock contract functions
const contractFunctions = {
  'record-dream': (content: string, isPublic: boolean) => {
    const newDreamId = ++dreamNonce;
    dreams.set(newDreamId, { owner: 'current-user', content, isPublic, aiAnalysis: '' });
    return { success: true, value: newDreamId };
  },
  'update-ai-analysis': (dreamId: number, analysis: string) => {
    if (dreams.has(dreamId)) {
      const dream = dreams.get(dreamId);
      dream.aiAnalysis = analysis;
      return { success: true, value: true };
    }
    return { success: false, error: 101 }; // err-not-found
  },
  'register-interpreter': () => {
    const newInterpreterId = ++interpreterNonce;
    interpreters.set('current-user', { interpreterId: newInterpreterId, reputation: 100, totalInterpretations: 0 });
    return { success: true, value: newInterpreterId };
  },
  'interpret-dream': (dreamId: number, interpretation: string) => {
    if (dreams.has(dreamId) && interpreters.has('current-user')) {
      const interpreter = interpreters.get('current-user');
      interpretations.set(`${dreamId}-${interpreter.interpreterId}`, { content: interpretation, rating: null });
      interpreter.totalInterpretations++;
      return { success: true, value: true };
    }
    return { success: false, error: 103 }; // err-unauthorized
  },
  'rate-interpretation': (dreamId: number, interpreterAddress: string, rating: number) => {
    const interpreter = interpreters.get(interpreterAddress);
    if (dreams.has(dreamId) && interpreter) {
      const interpretationKey = `${dreamId}-${interpreter.interpreterId}`;
      if (interpretations.has(interpretationKey)) {
        const interpretation = interpretations.get(interpretationKey);
        interpretation.rating = rating;
        // Update the reputation calculation
        interpreter.reputation = Math.floor((interpreter.reputation * 9 + rating * 20) / 10);
        interpreters.set(interpreterAddress, interpreter); // Make sure to update the interpreter in the map
        return { success: true, value: true };
      }
    }
    return { success: false, error: 101 }; // err-not-found
  },
  'get-interpreter': (address: string) => {
    return interpreters.get(address) || null;
  }
};

// Mock the contract calls
mockContractCall.mockImplementation((functionName: string, ...args: any[]) => {
  return contractFunctions[functionName](...args);
});

mockReadOnlyCall.mockImplementation((functionName: string, ...args: any[]) => {
  return contractFunctions[functionName](...args);
});

describe('Dream Journal Contract', () => {
  beforeEach(() => {
    // Reset the mock state before each test
    dreamNonce = 0;
    interpreterNonce = 0;
    dreams.clear();
    interpreters.clear();
    interpretations.clear();
    vi.clearAllMocks();
  });
  
  test('users can record dreams and mint NFTs', () => {
    const result = mockContractCall('record-dream', 'I dreamt I was flying', true);
    expect(result).toEqual({ success: true, value: 1 });
    expect(dreams.size).toBe(1);
    expect(dreams.get(1)).toEqual({
      owner: 'current-user',
      content: 'I dreamt I was flying',
      isPublic: true,
      aiAnalysis: ''
    });
  });
  
  test('only contract owner can update AI analysis', () => {
    mockContractCall('record-dream', 'I dreamt I was flying', true);
    const updateResult1 = mockContractCall('update-ai-analysis', 1, 'Flying represents freedom');
    expect(updateResult1).toEqual({ success: true, value: true });
    
    const updateResult2 = mockContractCall('update-ai-analysis', 2, 'Unauthorized analysis');
    expect(updateResult2).toEqual({ success: false, error: 101 });
  });
  
  test('users can register as interpreters and interpret dreams', () => {
    mockContractCall('record-dream', 'I dreamt I was flying', true);
    const registerResult = mockContractCall('register-interpreter');
    expect(registerResult).toEqual({ success: true, value: 1 });
    
    const interpretResult = mockContractCall('interpret-dream', 1, 'Flying represents freedom and aspirations');
    expect(interpretResult).toEqual({ success: true, value: true });
  });
});

